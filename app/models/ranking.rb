class Ranking < ActiveRecord::Base
  belongs_to :tenant

  validates_presence_of :tenant
  validates_uniqueness_of :url, :scope => [:extracted_on, :contents_type]

  def self.monthly(tenant, contents_type, year, month)
    sql = <<-SQL
      SELECT 
        recent.url, recent.title, recent.author, recent.author_url, recent. extracted_on,
        COALESCE(recent.amount - previous.amount, recent.amount) AS amount,
        recent.contents_type
      FROM (
          SELECT url, title, author, author_url, MAX(extracted_on) AS extracted_on, MAX(amount) AS amount, contents_type
          FROM rankings 
          WHERE rankings.tenant_id = :tenant_id
            AND rankings.contents_type = :contents_type
            AND rankings.extracted_on BETWEEN :beginning_of_month AND :end_of_month
          GROUP BY url
        ) AS recent 
      LEFT OUTER JOIN (
          SELECT url, title, author, author_url, MAX(extracted_on) AS extracted_on, MAX(amount) AS amount, contents_type
          FROM rankings 
          WHERE rankings.tenant_id = :tenant_id
            AND rankings.contents_type = :contents_type
            AND rankings.extracted_on <= :end_of_month_ago_1_month 
          GROUP BY url
      ) AS previous
        ON recent.url = previous.url 
      ORDER BY amount DESC
      LIMIT 10
    SQL
    time = Time.local(year, month)
    Ranking.find_by_sql([sql, {
      :tenant_id => tenant.id,
      :contents_type => contents_type.to_s,
      :beginning_of_month => time.beginning_of_month,
      :end_of_month => time.end_of_month,
      :end_of_month_ago_1_month => time.end_of_month.ago(1.month)
    }])
  end

  def self.total(tenant, contents_type)
    Ranking.tenant_id_is(tenant.id).contents_type_is(contents_type.to_s).all({
      :select => "url, title, author, author_url, MAX(extracted_on) AS extracted_on, MAX(amount) AS amount, contents_type",
      :limit => 10, :group => "url", :order => "amount DESC" 
    })
  end

  def self.extracted_dates(tenant)
    Ranking.all(:select => "DISTINCT DATE_FORMAT(extracted_on, '%Y-%m') as extracted_month", :order => 'extracted_on desc').map(&:extracted_month)
  end

end
