class Tenant < ActiveRecord::Base
  has_many :users, :dependent => :destroy
  has_many :board_entries, :dependent => :destroy
  has_many :share_files, :dependent => :destroy
  has_many :groups, :dependent => :destroy
  has_many :group_categories, :dependent => :destroy
  has_one :activation, :dependent => :destroy
  has_many :user_profile_master_categories, :dependent => :destroy
  has_many :user_profile_masters, :dependent => :destroy
  has_many :site_counts, :dependent => :destroy
  has_many :documents, :dependent => :destroy
  has_one :logo, :dependent => :destroy

  serialize :initial_settings

  validates_presence_of :initial_settings

  cattr_accessor :config_path
  @@config_path = File.expand_path("config/initial_settings.yml", Rails.root)

  def before_validation_on_create
    env = defined?(RAILS_ENV) ? RAILS_ENV : "development"
    self.initial_settings = YAML.load_file(@@config_path)[env]
  end

  def self.find_by_op_endpoint(endpoint)
    if endpoint.match(/^https:\/\/www\.google\.com\/a\/(.*)\/o8\/ud\?be=o8$/)
      self.find_by_op_url($1)
    else
      self.find_by_op_url(endpoint)
    end
  end

  # このテナントのHyperEstraierのNodeを取得
  def node
    @node ||= Search::SkipEstraierPure::Node.find_or_initialize_by_url(GlobalInitialSetting['estraier']['master_url'], "node#{self.id}", GlobalInitialSetting['estraier']['admin_id'], GlobalInitialSetting['estraier']['admin_password'])
  end

  # HyperEstraierのindexを再作成
  def reflesh_node
    self.node.clear
    self.users.active.each { |u| u.create_index }
    self.groups.active.each { |g| g.create_index }
    self.board_entries.each { |b| b.create_index }
    self.share_files.each { |s| s.create_index }
    true
  end
end
