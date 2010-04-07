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

Given /^メール機能を有効にする$/ do
  GlobalInitialSetting['mail']['show_mail_function'] = true
end

Given /^お知らせ機能を有効にする$/ do
  tenant.initial_settings['notice_entry']['enable'] = true
  tenant.save
end

Given /^Wiki機能を有効にする$/ do
  tenant.initial_settings['wiki']['use'] = true
  tenant.save
end

Given /^質問の告知方法の既定値をメール送信にする機能を"([^\"]*)"にする$/ do |str|
  if str == '有効'
    Admin::Setting.[]=(tenant, "default_send_mail_of_questiontenant", true)
  else
    Admin::Setting.[]=(tenant, "default_send_mail_of_questiontenant", false)
  end
end
