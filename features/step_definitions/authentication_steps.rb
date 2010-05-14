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

# TODO 使っている箇所を徐々に"以下のユーザを作成する"に置き換えていって無くす
#Given /^ログインIDが"(.*)"でパスワードが"(.*)"のあるユーザを作成する$/ do |id, password|
#  @user = create_user(:email => id, :password => password)
#end

Given /^"(.*)"でログインする$/ do |email|
  if @current_user
    if @current_user.email != email
      Given "ログアウトする"
      fill_in_login_form(email)
    else
      Given %!"#{@current_user.tenant.name}テナントのマイページ"にアクセスする!
    end
  else
    fill_in_login_form(email)
  end
end

Given /^"([^\"]*)"がユーザ登録する$/ do |user_id|
  create_user(user_id, 'Password1')
end

Given /^"([^\"]*)"が退職する$/ do |email|
  u = User.find_by_email(email)
  u.status = "RETIRED"
  u.save
end

Given /^ログアウトする$/ do
  visit logout_platform_path
end

# TODO Spec::Rails::Skip::ModelHelpers#create_userを使うように置き換えていって無くす
#def create_user(id, password)
#  uid = UserUid.find_by_uid(id)
#  uid.destroy if uid
#  u = User.new({ :name => id, :password => password, :password_confirmation => password, :reset_auth_token => nil, :email => "example#{id}@example.com" })
#  u.user_uids.build(:uid => id, :uid_type => 'MASTER')
#  u.build_user_access(:last_access => Time.now, :access_count => 0)
#  u.save!
#  u.status = "ACTIVE"
#  u.save!
#  u
#end
