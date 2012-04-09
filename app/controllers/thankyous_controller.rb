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

class ThankyousController < ApplicationController
  def create
    @thankyou = current_user.sent_thankyous.build params[:thankyou]
    if @thankyou.save
      UserMailer::AR.deliver_sent_thankyou(@thankyou)
    end
    respond_to do |format|
      format.js do
        render
      end
    end
  end

  def index
    @title = _("List of %s") % Thankyou.thankyou_label

    perpage = 10
    if params[:user]
      @thankyous = Thankyou.order_new.user_and_type(params[:user], params[:type]).paginate(:page => params[:page], :per_page => perpage)
    else
      @thankyous = Thankyou.order_new.user_like_and_type(params[:name], params[:type]).paginate(:page => params[:page], :per_page => perpage)
    end

    flash.now[:notice] = _('No matching results found.') if @thankyous.empty?

    respond_to do |format|
      format.html
    end
  end

end
