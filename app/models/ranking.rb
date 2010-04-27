class Ranking < ActiveRecord::Base
  belongs_to :tenant

  validates_presence_of :tenant
  validates_uniqueness_of :url, :scope => [:extracted_on, :contents_type]

end
