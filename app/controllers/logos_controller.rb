class LogosController < ApplicationController
  skip_before_filter :login_required, :only => :show
  before_filter :only => :show do |c|
    c.send(:login_required, {:allow_unused_user => true})
  end

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
