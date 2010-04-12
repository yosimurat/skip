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
#
module Spec
  module Rails
    module Skip
      module ControllerHelpers
        def admin_login
          session[:user_code] = '111111'
          session[:prepared] = true
          u = stub_model(User, :symbol => 'uid:admin', :admin => true, :name => '管理者', :crypted_password => '123456789')
          u.stub!(:active?).and_return(true)
          if defined? controller
            controller.stub!(:current_user).and_return(u)
          else
            # helperでも使えるように
            stub!(:current_user).and_return(u)
          end
          u
        end

        def user_login
          session[:user_code] = '111111'
          session[:prepared] = true
          u = stub_model(User, :symbol => 'uid:user', :admin => false, :name => '一般ユーザ', :crypted_password => '123456789', :code => "111111", :status => "ACTIVE", :created_on => 10.day.ago)
          u.stub!(:active?).and_return(true)
          u.stub!(:user_access).and_return(stub_model(UserAccess, :access_count => 4, :last_access => 1.day.ago))
          if defined? controller
            controller.stub!(:current_user).and_return(u)
          else
            # helperでも使えるように
            stub!(:current_user).and_return(u)
          end
          u
        end

        def unused_user_login
          session[:user_code] = '111111'
          session[:prepared] = true
          u = stub_model(User)
          u.stub!(:admin).and_return(false)
          u.stub!(:active?).and_return(false)
          u.stub!(:unused?).and_return(true)
          u.stub!(:name).and_return('未登録ユーザ')
          u.stub!(:crypted_password).and_return('123456789')
          if defined? controller
            controller.stub!(:current_user).and_return(u)
          else
            # helperでも使えるように
            stub!(:current_user).and_return(u)
          end
          u
        end

        def mock_uploaed_file options = {}
          file = mock('file', { :original_filename => "file1.png", :content_type => "image/png", :size => 1000, :read => "" }.merge(options))
          file.stub!(:is_a?).with(ActionController::UploadedFile).and_return(true)
          # 以下をやらないとパラメータの中身がHashかどうかのチェックがらしく、リクエストが飛ばなくなるので
          file.stub!(:is_a?).with(Hash).and_return(false)
          file.stub!(:is_a?).with(Array).and_return(false)
          file
        end
        # --- OpenID Provider関連テスト用
        def checkid_request_params
          { 'openid.ns' => OpenID::OPENID2_NS,
            'openid.mode' => 'checkid_setup',
            'openid.realm' => 'http://test.com/',
            'openid.trust_root' => 'http://test.com/',
            'openid.return_to' => 'http://test.com/return',
            'openid.claimed_id' => 'http://dennisbloete.de/',
            'openid.identity' => 'http://openid.innovated.de/dbloete' }
        end
        def identifier(user)
          "http://test.host/id/#{user.code}"
        end

        # --- flash.nowがRails 2.3 + RSpec 1.2.7でテストをパスしない問題に対する対応
        # https://rspec.lighthouseapp.com/projects/5645/tickets/98-11834-fake-controller-flash-object
        def stub_flash_now
          controller.instance_eval{flash.stub!(:sweep)}
        end
      end

      module ModelHelpers
        def mock_record_invalid
          fa = mock_model(ActiveRecord::Base)
          fa.errors.stub!(:full_messages).and_return([])
          ActiveRecord::RecordInvalid.new(fa)
        end

        def create_tenant options = {}
          t = Tenant.create!({:name => 'とあるテナント'}.merge(options))
          yield t if block_given?
          t
        end

        def create_user options = {}
          tenant = options[:tenant] || create_tenant
          user = tenant.users.build({ :name => 'ほげ ほげ', :password => 'Password1', :password_confirmation => 'Password1', :reset_auth_token => nil, :email => SkipFaker.email, :section => 'Programmer'}.merge(options))
          user.status = options[:status] || 'ACTIVE'
          user.admin = options[:admin] || false
          user.save!
          yield user if block_given?
          user
        end

        def valid_group_category
          group_category = GroupCategory.new({
            :code => 'DEPT',
            :name => '部署',
            :icon => 'group_gear',
            :description => '部署用のグループカテゴリ',
            :initial_selected => false
          })
          group_category
        end

        def create_group_category(options = {})
          tenant = options[:tenant] || create_tenant
          group_category = tenant.group_categories.build(valid_group_category.attributes.merge(options))
          group_category.save!
          group_category
        end

        def create_group(options = {})
          tenant = options[:tenant] || create_tenant
          group = tenant.groups.build({:name => 'SKIP開発', :description => 'SKIP開発中', :protected => false, :gid => 'skip_dev', :deleted_at => nil}.merge(options))
          group.deleted_at = options[:deleted_at]
          group.group_category_id = create_group_category(:initial_selected => true).id if group.group_category_id == 0
          yield group if block_given?
          group.save!
          group
        end

        def create_group_participation(options = {})
          group_participation = GroupParticipation.new({:user_id => 1, :group_id => 1, :waiting => 0, :owned => 0}.merge(options))
          group_participation.save!
          group_participation
        end

        def create_board_entry options = {}
          tenant = options[:tenant] || create_tenant
          owner = options[:owner] || create_user
          board_entry = tenant.board_entries.build({
            :title => 'とある記事',
            :contents => 'とある記事の内容',
            :date => Time.now,
            :user => (options[:user] || create_user(:tenant => tenant)),
            :last_updated => Time.now,
            :category => '',
            :publication_type => 'public',
            :owner => owner
          }.merge(options))
          board_entry.save!
          yield board_entry if block_given?
          board_entry
        end

        def create_board_entry_comment options = {}
          board_entry = options[:board_entry] || create_board_entry
          user = options[:user] || create_user
          board_entry_comment = board_entry.board_entry_comments.build({
            :contents => 'とあるコメント',
            :user => user
          }.merge!(options))
          board_entry_comment.save!
          board_entry_comment
        end

        def create_user_profile_master_category(options = {})
          profile_master_category = UserProfileMasterCategory.new({
            :name => '基本情報',
            :description => '基本情報のカテゴリです'
          }.merge(options))
          profile_master_category.save!
          profile_master_category
        end

        def create_user_profile_master(options = {})
          profile_master = UserProfileMaster.new({
            :user_profile_master_category_id => 1,
            :name => '自己紹介',
            :input_type => 'richtext'
          }.merge(options))
          profile_master.save_without_validation!
          profile_master
        end

        def create_user_reading(options = {})
          board_entry = options[:board_entry] || create_board_entry
          user = options[:user] || create_user
          board_entry.user_readings.create!({:user => user, :read => false, :checked_on => Time.now}.merge(options))
        end

        def create_system_message(options = {})
          system_message = SystemMessage.new({:send_flag => false, :message_hash => {:board_entry => 1}}.merge!(options))
          system_message.save!
          system_message
        end

        def create_user_message_unsubscribe(options = {})
          user = options[:user] || create_user
          user_message_unsubscribe = user.user_message_unsubscribes.create!({:message_type => 'MESSAGE'}.merge!(options))
          user_message_unsubscribe
        end
      end
    end
  end
end
