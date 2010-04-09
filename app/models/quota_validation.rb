module QuotaValidation
  include GetText
  def validates_size_per_file(file)
    if file.size == 0
      errors.add_to_base _("Nonexistent or empty files are not accepted for uploading.")
    elsif file.size > GlobalInitialSetting['max_share_file_size'].to_i
      errors.add_to_base _("Files larger than %sMBytes are not permitted.") % (GlobalInitialSetting['max_share_file_size'].to_i / 1.megabyte)
    end
  end

  def validates_size_per_tenant(file, tenant = self.tenant)
    if (tenant.total_file_size + file.size) > Admin::Setting.max_total_file_size_per_tenant(tenant)
      errors.add_to_base _("Upload denied due to excess of system wide shared files disk capacity.")
    end
  end
end
