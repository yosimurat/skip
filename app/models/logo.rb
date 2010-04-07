class Logo < ActiveRecord::Base
  belongs_to :tenant
  cattr_reader :valid_content_types, :valid_extensions, :valid_max_size
  @@valid_content_types = Types::ContentType::CONTENT_TYPE_IMAGES.values.map{|types| types.split(',')}.flatten.freeze
  @@valid_extensions = Types::ContentType::CONTENT_TYPE_IMAGES.keys
  @@valid_max_size = 300.kilobyte.freeze

  has_attached_file :logo,
    :path => ':attach_root/tenants/:tenant_id/:attachment/:id/:style/:basename.:extension',
    :url => '/tenants/:tenant_id/:attachment/:id/:style/:basename.:extension',
    :default_url => '/images/default_header_logo.png'

  validates_attachment_presence :logo
  validates_attachment_content_type :logo,
    :content_type => @@valid_content_types,
    :message =>  _('%{extension} formats are accepted.') % {:extension => @@valid_extensions.map(&:to_s).join(',')}
  validates_attachment_size :logo,
    :less_than => @@valid_max_size,
    :message =>  _('Maximum file size is %{size}Kbytes.') % {:size => @@valid_max_size/1.kilobyte}
end
