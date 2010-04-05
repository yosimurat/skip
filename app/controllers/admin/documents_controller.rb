# SKIP(Social Knowledge & Innovation Platform)
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

class Admin::DocumentsController < Admin::ApplicationController
  before_filter :valid_document_name_required

  N_('Admin::DocumentsController|about_this_site')
  N_('Admin::DocumentsController|about_this_site_description')
  N_('Admin::DocumentsController|rules')
  N_('Admin::DocumentsController|rules_description')

  def edit
    open_current_target_document do |doc|
      @document = doc
      @content_name = _(self.class.name + '|' + @document.name)
      @topics = topics
      @topics << @content_name
      respond_to do |format|
        format.html
      end
    end
  end

  def update
    open_current_target_document do |doc|
      @document = doc
      @document.value = params[:admin_document][:value]
      @content_name = _(self.class.name + '|' + @document.name)
      @topics = topics
      @topics << @content_name
      if @document.save
        respond_to do |format|
          format.html { redirect_to edit_admin_tenant_document_path(current_tenant, @document.name) }
        end
      else
        respond_to do |format|
          format.html { render :edit }
        end
      end
    end
  end

  def revert
    open_current_target_document do |doc|
      unless doc.new_record?
        doc.value = Admin::Document.default_document_value(doc.name)
      end
      @document = doc
      @content_name = _(self.class.name + '|' + @document.name)
      @topics = topics
      @topics << @content_name
      # ここではエラー起きない想定
      @document.save
      respond_to do |format|
        format.html { redirect_to edit_admin_tenant_document_path(current_tenant, @document.name) }
      end
    end
  end

  private
  def valid_document_name_required
    unless Admin::Document::DOCUMENT_NAMES.include?(params[:id])
      render_404
      false
    end
  end

  def open_current_target_document
    document_name = params[:id]
    document =
      if d = Admin::Document.tenant_id_is(current_tenant.id).find_by_name(document_name)
        d
      else
        Admin::Document.new({
          :name => document_name,
          :value => Admin::Document.default_document_value(document_name),
          :tenant => current_tenant
        })
      end
    yield document if block_given?
    document
  rescue Errno::EACCES => e
    flash.now[:error] = _('Failed to open the content.')
    render :status => :forbidden
  rescue Errno::ENOENT => e
    flash.now[:error] = _('Content not found.')
    render :status => :not_found
  rescue => e
    flash.now[:error] = _('Unexpected error occured. Contact administrator.')
    logger.error e
    e.backtrace.each { |message| logger.error message }
    render :status => :internal_server_error
  end

  def topics
    [[_('Admin::DocumentsController'), edit_admin_tenant_document_path(current_tenant, params[:id])]]
  end
end
