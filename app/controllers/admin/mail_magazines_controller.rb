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


class Admin::MailMagazinesController < Admin::ApplicationController

  def create
    if params[:mail_magazine]
      unless params[:mail_magazine][:title].blank? or params[:mail_magazine][:contents].blank?
        if params[:mail_magazine][:preview_only] == '1'
          UserMailer::AR.deliver_sent_mail_magazine(Admin::Setting.contact_addr, params[:mail_magazine])
          flash.now[:notice] = _("Mail magazines were sucessfully sended.") + _('(The administorator only)')
          render :new
        else
          User.active.each do |user|
            UserMailer::AR.deliver_sent_mail_magazine(user.email, params[:mail_magazine])
          end
          flash[:notice] = _("Mail magazines were sucessfully sended.")
          redirect_to new_admin_mail_magazine_path
        end
      else
        flash.now[:error] = _("Input title and contents.")
        render :new
      end
    else
      flash.now[:error] = _("Input title and contents.")
      render :new
    end
  end
end
