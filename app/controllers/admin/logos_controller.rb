class Admin::LogosController < Admin::ApplicationController
  def update
    @logo = Admin::Logo.tenant_id_is(current_tenant.id).first || Admin::Logo.new
    @logo.attributes = params[:admin_logo]
    @logo.tenant = current_tenant
    respond_to do |format|
      if @logo.save
        flash[:notice] = _('%{target} was successfully saved.' % {:target => _("logo")})
        format.html { redirect_to admin_tenant_images_path(current_tenant) }
      else
        flash.now[:error] = @logo.errors.full_messages
        format.html { render :template => 'admin/images/index' }
      end
    end
  end

  def destroy
    if logo = Admin::Logo.tenant_id_is(current_tenant.id).first
      logo.destroy
    end
    respond_to do |format|
      format.html { redirect_to admin_tenant_images_path(current_tenant) }
    end
  end
end
