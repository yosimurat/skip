Paperclip.interpolates :attach_root do |attachment, style|
  GlobalInitialSetting['attach_path'] || 'tmp/attach_path'
end

Paperclip.interpolates :tenant_id do |attachment, style|
  attachment.instance.tenant.id
end
