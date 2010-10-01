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

class Admin::BannersController < Admin::ApplicationController
  include Admin::AdminModule::AdminRootModule

  def index
    @banners = Admin::Banner.all
  end

  def new
    @banner = Admin::Banner.new
  end

  def create
    @banner = Admin::Banner.new(params[:admin_banner])
    if @banner.save
      respond_to do |format|
        flash[:notice] = _('Created successfully.')
        format.html { redirect_to admin_banners_path }
      end
    else
      respond_to do |format|
        flash[:warn] = _('Specified URL is invalid.')
        format.html { render :action => 'new' }
      end
    end
  end

  def edit
    @banner = Admin::Banner.find(params[:id])
  end

  def update
    @banner = Admin::Banner.find(params[:id])
    if @banner.update_attributes(params[:admin_banner])
      respond_to do |format|
        flash[:notice] = _('Updated successfully.')
        format.html { redirect_to admin_banners_path }
      end
    else
      respond_to do |format|
        flash[:warn] = _('Specified URL is invalid.')
        format.html { render :action => 'edit' }
      end
    end
  end

  def destroy
    banner = Admin::Banner.find(params[:id])
    banner.destroy if banner
    respond_to do |format|
      format.html { redirect_to admin_banners_path }
    end
  end
end
