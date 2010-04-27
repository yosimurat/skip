# SKIP（Social Knowledge & Innovation Platform）
# Copyright (C) 2008-2010 TIS Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path(File.dirname(__FILE__) + "/batch_base")

# 1日分のランキング元データを生成
# 送信するデータは、送信日時点でのこれまでの累積値(!=前日からの差分)
# 表示時には、本バッチで生成したデータを集計するのみ。
class BatchMakeRanking < BatchBase
  def self.execute options
    @maker = BatchMakeRanking.new

    begin
      log_info '[START] make rankings'
      ActiveRecord::Base.transaction do
        (options[:from]..options[:to]).each do |exec_date|
          start = Time.now
          log_info "[START] make ranking at #{exec_date}"
          # バッチのリラン用
          Ranking.destroy_all(['extracted_on = ?', exec_date])

          # アクセス数
          @maker.create_access_ranking exec_date

          # へー
          @maker.create_point_ranking exec_date

          # コメント数
          @maker.create_comment_ranking exec_date

          # 投稿数
          @maker.create_post_ranking exec_date

          # 訪問者数
          @maker.create_visited_ranking exec_date

          # コメンテータ
          @maker.create_commentator_ranking exec_date
          log_info "[END] make ranking at #{exec_date} %2fsec"%(Time.now - start).to_f
        end
      end
      log_info '[END] make rankings'
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
      e.backtrace.each { |line| log_error line}
    end
  end

  def create_access_ranking exec_date
    BoardEntryPoint.find(:all, :conditions => make_conditions("access_count > 0", exec_date), :include => {:board_entry => :tenant}).map do |entrypoint|
      entry = entrypoint.board_entry
      if entry.public?
        create_ranking_by_entry entry, entrypoint.access_count, "entry_access", exec_date
      end
    end
  end

  def create_point_ranking exec_date
    BoardEntryPoint.find(:all, :conditions => make_conditions("point > 0", exec_date), :include => {:board_entry => :tenant}).each do |entrypoint|
      entry = entrypoint.board_entry
      if entry.public?
        create_ranking_by_entry entry, entrypoint.point, "entry_he", exec_date
      end
    end
  end

  def create_comment_ranking exec_date
    BoardEntryComment.find(:all, :conditions => ["DATE_FORMAT(created_on, '%Y%m%d') = ?", exec_date.strftime('%Y%m%d')], :include => [{:board_entry => :tenant}, :user], :group => :board_entry_id).each do |entry_comment|
      entry = entry_comment.board_entry
      if entry.public?
        create_ranking_by_entry entry, entry.board_entry_comments_count, "entry_comment", exec_date
      end
    end
  end

  def create_post_ranking exec_date
    BoardEntry.find(
      :all, :conditions => [" entry_type = 'DIARY' AND DATE_FORMAT(created_on,'%Y%m%d') <= ? ", exec_date.strftime('%Y%m%d')],
      :select => "user_id, COUNT(*) as user_entry_no",
      :include => {:user => :tenant},
      :group => "user_id").each do |record|
        create_ranking_by_user record.user, record.user_entry_no, "user_entry", exec_date
      end
  end

  def create_visited_ranking exec_date
    UserAccess.find(:all, :conditions => ["access_count > 0 AND DATE_FORMAT(updated_on,'%Y%m%d') = ? ", exec_date.strftime('%Y%m%d')], :include => {:user => :tenant}).each do |access|
      create_ranking_by_user access.user, access.access_count, "user_access", exec_date
    end
  end

  def create_commentator_ranking exec_date
    # skip上に累積値を持たないため、導出
    sql = <<-SQL
          SELECT user_id,COUNT(*) AS comment_count
          FROM board_entry_comments
          WHERE user_id IN (
            SELECT distinct user_id
            FROM board_entry_comments
            WHERE DATE_FORMAT(updated_on,'%Y%m%d') = :commentator_conditions
          )
          -- 6月1日から9月1日で実行する場合に、6月1日分のデータを生成する際に6月1以前の分のみ対象にするため
          -- (6月1日以降のデータ入ってしまうと正常なデータにならない)
          AND DATE_FORMAT(updated_on,'%Y%m%d') <= :commentator_conditions
          GROUP BY user_id
          SQL
    BoardEntryComment.find_by_sql([sql, { :commentator_conditions => exec_date.strftime('%Y%m%d'), :include => {:user => :tenant} }]).each do |record|
      create_ranking_by_user record.user, record.comment_count, "commentator", exec_date
    end
  end

  private
  def make_conditions condition, exec_date
    [condition + " AND DATE_FORMAT(updated_on,'%Y%m%d') = ? ", exec_date.strftime('%Y%m%d')]
  end

  def create_ranking tenant, url, title, author, author_url, amount, contents_type, exec_date
    ranking = tenant.rankings.build(
      :url => url,
      :title => title,
      :author => author,
      :author_url => author_url,
      :extracted_on => exec_date,
      :amount => amount,
      :contents_type => contents_type
    )
    ranking.save!
  end

  def create_ranking_by_entry entry, amount, contents_type, exec_date
    create_ranking entry.tenant, polymorphic_url([entry.tenant, entry]), entry.title, entry.user.name,
      polymorphic_url([entry.user.tenant, entry.user]), amount, contents_type, exec_date
  end

  def create_ranking_by_user user, amount, contents_type, exec_date
    url = polymorphic_url([user.tenant, user])
    create_ranking user.tenant, url, user.name, user.name,
      url, amount, contents_type, exec_date
  end
end


unless RAILS_ENV == 'test'
  # 引数は、シェルからの実行用。集計対象日を'YYYYMMDD'形式で渡せる。
  # cronからの日次実行時には、引数は不要。
  def parse_date str
    begin
      Date.parse(str)
    rescue => e
      BatchBase.log_error e
      e.backtrace.each { |line| BatchBase.log_error line }
      exit
    end
  end

  from = ARGV[0]
  to   = ARGV[1]

  unless to
    from = to = from ? parse_date(from) : Date.today.yesterday
    BatchMakeRanking.execution({:from => from, :to => to})
  else
    from = parse_date(from)
    to = parse_date(to)
    BatchMakeRanking.execution({:from => from, :to => to})
  end
end
