class LogosController < ApplicationController
  skip_before_filter :prepare_session, :only => :show
  def show
    if logo = current_tenant.logo
      if stale?(:etag => logo, :last_modified => logo.logo_updated_at)
        send_data(File.open(logo.logo.path) { |f| f.read }, :filename => logo.logo_file_name, :type => logo.logo_content_type, :disposition => 'inline')
      end
    else
      render_404
    end
  end
end
