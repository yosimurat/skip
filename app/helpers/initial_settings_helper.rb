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

module InitialSettingsHelper
  def login_mode?(mode, tenant = current_tenant)
    case mode
    when :password
      return !(tenant and tenant.op_url)
    when :fixed_rp
      return !!(tenant and tenant.op_url)
    else
      return false
    end
  end

  def enable_activate? tenant = current_tenant
    login_mode?(:password, tenant) && !Admin::Setting.stop_new_user(tenant) && GlobalInitialSetting['mail']['show_mail_function']
  end

  def enable_signup? tenant = current_tenant
    login_mode?(:password, tenant)
  end

  def enable_forgot_password?
    login_mode?(:password) && GlobalInitialSetting['mail']['show_mail_function']
  end

  def enable_forgot_openid?
    login_mode?(:free_rp) && GlobalInitialSetting['mail']['show_mail_function']
  end
end
