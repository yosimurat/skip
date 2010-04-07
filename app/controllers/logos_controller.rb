class LogosController < ApplicationController
  def show
    logo = current_tenant.logo
    if stale?(:etag => logo, :last_modified => logo.logo_updated_at)
      send_data(File.open(logo.logo.path) { |f| f.read }, :filename => logo.logo_file_name, :type => logo.logo_content_type, :disposition => 'inline')
    end
  end
end
