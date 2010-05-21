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

require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sug = create_tenant(:name => 'SKIPUserGroup')
  end
  describe User, 'valid?' do
    subject {
      @user = User.new(:name => @name, :email => @email, :tenant => @tenant, :login => @login, :password => @password, :password_confirmation => @password_confirmation)
      @user.status = (@status || 'UNUSED')
      @user.valid?
      @user
    }
    describe 'name' do
      context '空の場合' do
        before { @name = '' }
        it { should have(1).errors_on(:name) }
      end
      context '60文字を越える場合' do
        before { @name = 'a'*61 }
        it { should have(1).errors_on(:name) }
      end
      context '正しい場合' do
        before { @name = 'alice' }
        it { should have(0).errors_on(:name) }
      end
    end
    describe 'email' do
      context '指定emailのユーザが既に存在する' do
        before do
          @email = 'alice@test.com'
          create_user(:email => @email)
        end
        it { should have(1).errors_on(:email) }
      end
      context 'ドメイン名に大文字を含む' do
        before do
          @email = 'alice@Test.com'
        end
        it { should have(0).errors_on(:email) }
      end
      context 'アカウント名とドメイン名に大文字を含む' do
        before do
          @email = 'Alice@Test.com'
        end
        it { should have(0).errors_on(:email) }
      end
      context '正しい場合' do
        before do
          @email = 'alice@test.com'
        end
        it { should have(0).errors_on(:email) }
      end
    end
    describe 'tenant' do
      context '指定されていない' do
        before { @tenant = nil }
        it { should have(1).errors_on(:tenant) }
      end
      context '正しい場合' do
        before { @tenant = create_tenant }
        it { should have(0).errors_on(:tenant) }
      end
    end

    describe 'login' do
      context '@を含む' do
        before { @login = 'aa@bb' }
        it { should have(1).errors_on(:login) }
      end
      context '-_.を含む' do
        before { @login = 'aa-.bb_' }
        it { should have(0).errors_on(:login) }
      end
      context 'nilの場合' do
        before { @login = nil }
        it { should have(0).errors_on(:login) }
      end
      context '同一テナント内に登録済みの場合' do
        before do
          @tenant = create_tenant
          @login = 'alice'
          create_user(:tenant => @tenant, :login => @login)
        end
        it { should have(1).errors_on(:login) }
      end
      context '異なるテナント内に登録済みの場合' do
        before do
          @tenant = create_tenant
          @login = 'alice'
          create_user(:tenant => create_tenant, :login => @login)
        end
        it { should have(0).errors_on(:login) }
      end
      context '最小の長さが3に設定されている' do
        before do
          @tenant = create_tenant
          Admin::Setting.set_user_code_minimum_length(@tenant, 3)
        end
        context '長さが2の場合' do
          before { @login = 'al' }
          it { should have(1).errors_on(:login) }
        end
        context '長さが3の場合' do
          before { @login = 'ali' }
          it { should have(0).errors_on(:login) }
        end
        after do
          Admin::Setting.set_user_code_minimum_length(@tenant, 4)
        end
      end
    end

    describe 'password' do
      before { @status = 'ACTIVE'; @tenant = create_tenant; @login = 'login' }
      context '空の場合' do
        before { @password = '' }
        it { should have(1).errors_on(:password) }
        it { subject.errors.on(:password).should == 'Password is too short (minimum is 6 characters)' }
      end
      context '6文字以上である' do
        context '5文字の場合' do
          before { @password = 'Pass1' }
          it { should have(2).errors_on(:password) }
          it { subject.errors.on(:password).should be_include('Password is too short (minimum is 6 characters)') }
        end
        context '6文字の場合' do
          before { @password = 'Passw1' }
          it { should have(1).errors_on(:password) }
          it { subject.errors.on(:password).should_not be_include('Password is too short (minimum is 6 characters)') }
        end
      end
      context '40文字以内である' do
        context '40文字の場合' do
          before { @password = 'p'*40 }
          it { should have(1).errors_on(:password) }
          it { subject.errors.on(:password).should_not be_include('Password is too long (maximum is 40 characters)') }
        end
        context '41文字の場合' do
          before { @password = 'p'*41 }
          it { should have(2).errors_on(:password) }
          it { subject.errors.on(:password).should be_include('Password is too long (maximum is 40 characters)') }
        end
      end
      context '確認用パスワードと一致しない' do
        before { @password = 'Password1'; @password_confirmation = 'Password2' }
        it { should have(1).errors_on(:password) }
        it { subject.errors.on(:password).should be_include('Password doesn\'t match confirmation') }
      end
      context '保存済みのパスワードと同じ' do
        before do
          @alice = create_user(:password => 'Password1', :password_confirmation => 'Password1')
          @alice.password = 'Password1'
          @alice.password_confirmation = 'Password1'
        end
        subject {
          @alice.valid?
          @alice
        }
        it { should have(1).errors_on(:password) }
        it { subject.errors.on(:password).should be_include('shall not be the same with the previous one.') }
      end
      describe 'パスワード強度が弱の場合' do
        before do
          @tenant = create_tenant
          Admin::Setting.set_password_strength(@tenant, 'low')
        end
        context 'パスワードがabcde' do
          before { @password = 'abcde' }
          it { should have(2).errors_on(:password) }
        end
        context 'パスワードがabcdef' do
          before { @password = 'abcdef' }
          it { should have(1).errors_on(:password) }
        end
      end
      describe 'パスワード強度が中の場合' do
        before do
          @tenant = create_tenant
          Admin::Setting.set_password_strength(@tenant, 'middle')
        end
        context 'パスワードが7文字英数字' do
          before { @password = 'abcdeF0' }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字英字のみ' do
          before { @password = 'a'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の大文字英字のみ' do
          before { @password = 'A'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の数字のみ' do
          before { @password = '1'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の記号のみ' do
          before { @password = '#'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字、大文字のみ' do
          before { @password = 'a'*4 + 'A'*4 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字、大文字、数字混在' do
          before { @password = 'aaaAAA12' }
          it { should have(0).errors_on(:password) }
        end
      end
      describe 'パスワード強度が強の場合' do
        before do
          @tenant = create_tenant
          Admin::Setting.set_password_strength(@tenant, 'high')
        end
        context 'パスワードが7文字英数字' do
          before { @password = 'abcdeF0' }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字英字のみ' do
          before { @password = 'a'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の大文字英字のみ' do
          before { @password = 'A'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の数字のみ' do
          before { @password = '1'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の記号のみ' do
          before { @password = '#'*8 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字、大文字のみ' do
          before { @password = 'a'*4 + 'A'*4 }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字、大文字、数字混在' do
          before { @password = 'aaaAAA12' }
          it { should have(1).errors_on(:password) }
        end
        context 'パスワードが8文字の小文字、大文字、数字、記号混在' do
          before { @password = 'aaaAAA1#' }
          it { should have(0).errors_on(:password) }
        end
      end
    end
  end

  describe User, "#before_save" do
    before do
      #tenant.update_attribute :op_url, nil
      GlobalInitialSetting['sha1_digest_key'] = "digest_key"
    end
    describe '新規の場合' do
      before do
        @user = valid_user(:tenant => @sg)
        Admin::Setting.set_password_change_interval(@sg, 90)
      end
      it 'パスワードが保存されること' do
        lambda do
          @user.save
        end.should change(@user, :crypted_password).from(nil)
      end
      it 'パスワード有効期限が設定されること' do
        time = Time.now
        Time.stub!(:now).and_return(time)
        lambda do
          @user.save
        end.should change(@user, :password_expires_at).to(Time.now.since(90.day))
      end
    end

    describe '更新の場合' do
      before do
        @user = valid_user(:tenant => @sg)
        @user.save
        @user.reset_auth_token = 'reset_auth_token'
        @user.reset_auth_token_expires_at = Time.now
        @user.locked = true
        @user.trial_num = 1
        @user.save
        Admin::Setting.set_password_change_interval(@sg, 90)
      end
      describe 'パスワードの変更の場合' do
        before do
          @user.password = 'Password99'
          @user.password_confirmation = 'Password99'
        end
        it 'パスワードが保存される' do
          lambda do
            @user.save
          end.should change(@user, :crypted_password).from(nil)
        end
        it 'パスワード有効期限が設定される' do
          time = Time.now
          Time.stub!(:now).and_return(time)
          lambda do
            @user.save
          end.should change(@user, :password_expires_at).to(Time.now.since(90.day))
        end
        it 'reset_auth_tokenがクリアされること' do
          lambda do
            @user.save
          end.should change(@user, :reset_auth_token).to(nil)
        end
        it 'reset_auth_token_expires_atがクリアされること' do
          lambda do
            @user.save
          end.should change(@user, :reset_auth_token_expires_at).to(nil)
        end
        it 'lockedがクリアされること' do
          lambda do
            @user.save
          end.should change(@user, :locked).to(false)
        end
        it 'trial_numがクリアされること' do
          lambda do
            @user.save
          end.should change(@user, :trial_num).to(0)
        end
      end

      describe 'パスワード以外の変更の場合' do
        before do
          @user.name = 'fuga'
        end
        it 'パスワードは変更されないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :crypted_password)
        end
        it 'パスワード有効期限は設定されないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :password_expires_at)
        end
        it 'reset_auth_tokenが変わらないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :reset_auth_token)
        end
        it 'reset_auth_token_expires_atが変わらないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :reset_auth_token_expires_at)
        end
        it 'lockedが変わらないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :locked)
        end
        it 'trial_numが変わらないこと' do
          lambda do
            @user.save
          end.should_not change(@user, :trial_num)
        end
      end
    end

    describe 'ロックする場合' do
      before do
        @user = create_user({
          :tenant => @sg,
          :auth_session_token => 'auth_session_token',
          :remember_token => 'remember_token',
          :remember_token_expires_at => Time.now
        })
        @user.locked = true
      end
      it 'セッション認証用のtokenが破棄されること' do
        lambda do
          @user.save
        end.should change(@user, :auth_session_token).to(nil)
      end
      it 'クッキー認証用のtokenが破棄されること' do
        lambda do
          @user.save
        end.should change(@user, :remember_token).to(nil)
      end
      it 'クッキー認証用のtokenの有効期限が破棄されること' do
        lambda do
          @user.save
        end.should change(@user, :remember_token_expires_at).to(nil)
      end
    end

    describe 'ロック状態が変化しない場合' do
      before do
        @user = create_user({
          :tenant => @sg,
          :auth_session_token => 'auth_session_token',
          :remember_token => 'remember_token',
          :remember_token_expires_at => Time.now
        })
      end
      it 'セッション認証用のtokenが破棄されないこと' do
        lambda do
          @user.save
        end.should_not change(@user, :auth_session_token)
      end
      it 'クッキー認証用のtokenが破棄されないこと' do
        lambda do
          @user.save
        end.should_not change(@user, :remember_token)
      end
      it 'クッキー認証用のtokenの有効期限が破棄されないこと' do
        lambda do
          @user.save
        end.should_not change(@user, :remember_token_expires_at)
      end
    end
  end

  describe User, '#before_create' do
    before do
      @user = valid_user(:tenant => @sg)
    end
    it '新規作成の際にはissued_atに現在日時が設定される' do
      time = Time.now
      Time.stub!(:now).and_return(time)
      lambda do
        @user.save
      end.should change(@user, :issued_at).to(nil)
    end
  end

  describe User, ".auth" do
    subject {
      User.auth(@auth_email, @auth_password)
    }

    describe "指定したログインID又はメールアドレスに対応するユーザが存在する場合" do
      describe "未使用ユーザの場合" do
        before do
          @user = create_user(:tenant => @sg, :email => 'sg_alice@test.com', :password => 'Password1', :password_confirmation => 'Password1', :status => 'UNUSED')
          @auth_email = 'sg_alice@test.com'
          @auth_password = 'Password1'
        end
        it { should be_false }
      end
      describe "使用中ユーザの場合" do
        before do
          @user = create_user(:tenant => @sg, :email => 'sg_alice@test.com', :password => 'Password1', :password_confirmation => 'Password1', :status => 'ACTIVE')
        end
        describe "パスワードが正しい場合" do
          before do
            @auth_email = 'sg_alice@test.com'
            @auth_password = 'Password1'
            User.should_receive(:auth_successed).with(@user)
          end
          it { should be_true }
        end
        describe "パスワードは正しくない場合" do
          before do
            @auth_email = 'sg_alice@test.com'
            @auth_password = 'invalid'
            # FIXME なぜか2回呼ばれる。原因を調べる
            User.should_receive(:auth_failed).with(@user)
          end
          it { should be_false }
        end
        describe "パスワードの有効期限が切れている場合" do
          before do
            @auth_email = 'sg_alice@test.com'
            @auth_password = 'Password1'
            @user.password_expires_at = Time.now.ago(1.day)
            @user.save
          end
          it { should be_false }
        end
        describe "アカウントがロックされている場合" do
          before do
            @auth_email = 'sg_alice@test.com'
            @auth_password = 'Password1'
            @user.locked = true
            @user.save
          end
          it { should be_false }
        end
      end
    end
  end

  describe User, '.grouped_sections' do
    before do
      User.delete_all
      create_user :tenant => @sg, :email => SkipFaker.email, :section => 'Programmer'
      create_user :tenant => @sg, :email => SkipFaker.email, :section => 'Programmer'
      create_user :tenant => @sg, :email => SkipFaker.email, :section => 'Tester'
      create_user :tenant => @sug, :email => SkipFaker.email, :section => 'Vimmer'
    end
    it {User.grouped_sections.size.should == 3}
    it {@sg.users.grouped_sections.size.should == 2}
    it {@sug.users.grouped_sections.size.should == 1}
  end

  describe User, ".new_with_identity_url" do
    before do
      @identity_url = "http://test.com/identity"
      @params = { :code => 'hoge', :name => "ほげ ふが", :email => 'hoge@hoge.com', :tenant => @sg }
      @user = User.new_with_identity_url(@identity_url, @params)
      @user.stub!(:password_required?).and_return(false)
    end
    describe "正しく保存される場合" do
      it { @user.should be_valid }
      it { @user.should be_is_a(User) }
      it { @user.openid_identifiers.should_not be_nil }
      it { @user.openid_identifiers.map{|i| i.url}.should be_include(@identity_url) }
    end
    describe "バリデーションエラーの場合" do
      before do
        @user.name = ''
        @user.email = ''
      end
      it { @user.should_not be_valid }
      it "userにエラーが設定されていること" do
        @user.valid?
        @user.errors.full_messages.size.should == 3
      end
    end
  end

  describe User, ".create_with_identity_url" do
    before do
      @identity_url = "http://test.com/identity"
      @params = { :code => 'hoge', :name => "ほげ ふが", :email => 'hoge@hoge.com', :tenant => @sg}

      @user = mock_model(User)
      User.should_receive(:new_with_identity_url).and_return(@user)

      @user.should_receive(:save)
    end
    it { User.create_with_identity_url(@identity_url, @params).should be_is_a(User) }
  end

  describe User, '.issue_activation_codes' do
    before do
      @now = Time.local(2008, 11, 1)
      User.stub!(:activation_lifetime).and_return(2)
      Time.stub!(:now).and_return(@now)
    end
    describe '指定したIDのユーザが存在する場合' do
      before do
        @user = create_user(:tenant => @sg, :status => 'UNUSED')
      end
      it '未使用ユーザのactivation_tokenに値が入ること' do
        unused_users, active_users = User.issue_activation_codes(@sg, [@user.id])
        unused_users.first.activation_token.should_not be_nil
      end
      it '未使用ユーザのactivation_token_expires_atが48時間後となること' do
        unused_users, active_users = User.issue_activation_codes(@sg, [@user.id])
        unused_users.first.activation_token_expires_at.should == @now.since(48.hour)
      end
    end
  end

  describe User, '.activation_lifetime' do
    describe 'activation_lifetimeの設定が3(日)の場合' do
      before do
        @activation_lifetime_was = Admin::Setting.activation_lifetime(@sg)
        Admin::Setting.set_activation_lifetime(@sg, 3)
      end
      it { User.activation_lifetime(@sg).should == 3 }
      after do
        Admin::Setting.set_activation_lifetime(@sg, @activation_lifetime_was)
      end
    end
  end

  describe User, '#change_password' do
    before do
      @sg.update_attribute :op_url, nil
      GlobalInitialSetting['sha1_digest_key'] = 'digest_key'
      @user = create_user(:tenant => @sg, :password => 'Password1')
      @old_password = 'Password1'
      @new_password = 'Hogehoge1'

      @params = { :old_password => @old_password, :password => @new_password, :password_confirmation => @new_password }
    end
    describe "前のパスワードが正しい場合" do
      describe '新しいパスワードが入力されている場合' do
        it 'パスワードが変更されること' do
          lambda do
            @user.change_password @params
          end.should change(@user, :crypted_password)
        end
      end
      describe '新しいパスワードが入力されていない場合' do
        before do
          @params[:password] = ''
          @user.change_password @params
        end
        it { @user.errors.full_messages.size.should == 1 }
      end
    end
    describe "前のパスワードが間違っている場合" do
      before do
        @params[:old_password] = 'fugafuga'
        @user.change_password @params
      end
      it { @user.errors.full_messages.size.should == 1 }
    end
  end

  describe User, '#before_access' do
    it { pending '後で回帰テストを書く' }
  end

  describe User, '#mark_track' do
    it { pending '後で回帰テストを書く' }
  end

  describe User, '#locked?' do
    before do
      @user = create_user(:tenant => @sg)
      @enable_user_lock_was = Admin::Setting.enable_user_lock(@sg)
    end
    describe 'ユーザロック機能が有効な場合' do
      before do
        Admin::Setting.set_enable_user_lock(@sg, 'true')
      end
      describe 'ユーザがロックされている場合' do
        before do
          @user.locked = true
        end
        it 'ロックされていると判定されること' do
          @user.locked?.should be_true
        end
      end
      describe 'ユーザがロックされていない場合' do
        before do
          @user.locked = false
        end
        it 'ロックされていないと判定されること' do
          @user.locked?.should be_false
        end
      end
    end
    describe 'ユーザロック機能が無効な場合' do
      before do
        Admin::Setting.set_enable_user_lock(@sg, 'false')
      end
      describe 'ユーザがロックされている場合' do
        before do
          @user.locked = true
        end
        it 'ロックされていると判定されること' do
          @user.locked?.should be_true
        end
      end
      describe 'ユーザがロックされていない場合' do
        before do
          @user.locked = false
        end
        it 'ロックされていないと判定されること' do
          @user.locked?.should be_false
        end
      end
    end
    after do
      Admin::Setting.set_enable_user_lock(@sg, @enable_user_lock_was)
    end
  end

  describe User, "#delete_auth_tokens!" do
    before do
      @user = create_user(:tenant => @sg)
      @user.remember_token = "remember_token"
      @user.remember_token_expires_at = Time.now
      @user.auth_session_token = "auth_session_token"
      @user.save

      @user.delete_auth_tokens!
    end
    it "すべてのトークンが削除されていること" do
      @user.remember_token.should be_nil
      @user.remember_token_expires_at.should be_nil
      @user.auth_session_token.should be_nil
    end
  end

  describe User, "#update_auth_session_token" do
    before do
      @user = create_user(:tenant => @sg)
      @auth_session_token = User.make_token
      User.stub!(:make_token).and_return(@auth_session_token)
      @enable_single_session_was = Admin::Setting.enable_single_session(@sg)
    end
    describe 'シングルセッション機能が有効な場合' do
      before do
        Admin::Setting.set_enable_single_session(@sg, 'true')
      end
      it "トークンが保存されること" do
        @user.update_auth_session_token!
        @user.auth_session_token.should == @auth_session_token
      end
      it "トークンが返されること" do
        @user.update_auth_session_token!.should == @auth_session_token
      end
    end
    describe 'シングルセッション機能が無効な場合' do
      before do
        Admin::Setting.set_enable_single_session(@sg, 'false')
      end
      describe '新規ログインの場合(auth_session_tokenに値が入っていない)' do
        before do
          @user.auth_session_token = nil
        end
        it "トークンが保存されること" do
          @user.update_auth_session_token!
          @user.auth_session_token.should == @auth_session_token
        end
        it "トークンが返されること" do
          @user.update_auth_session_token!.should == @auth_session_token
        end
      end
      describe 'ログイン済みの場合(auth_session_tokenに値が入っている)' do
        before do
          @user.auth_session_token = 'auth_session_token'
        end
        it 'トークンが変化しないこと' do
          lambda do
            @user.update_auth_session_token!
          end.should_not change(@user, :auth_session_token)
        end
        it 'トークンが返されること' do
          @user.update_auth_session_token!.should == 'auth_session_token'
        end
      end
    end
    after do
      Admin::Setting.set_enable_single_session(@sg, @enable_single_session_was)
    end
  end

  describe User, '#issue_reset_auth_token' do
    before do
      @user = create_user(:tenant => @sg)
      @now = Time.local(2008, 11, 1)
      Time.stub!(:now).and_return(@now)
    end
    it 'reset_auth_tokenに値が入ること' do
      lambda do
        @user.issue_reset_auth_token
      end.should change(@user, :reset_auth_token)
    end
    it 'reset_auth_token_expires_atが24時間後となること' do
      lambda do
        @user.issue_reset_auth_token
      end.should change(@user, :reset_auth_token_expires_at).from(nil).to(@now.since(24.hour))
    end
  end

  describe User, '#determination_reset_auth_token' do
    before do
      @user = create_user(:tenant => @sg)
    end
    it 'reset_auth_tokenの値が更新されること' do
      prc = '6df711a1a42d110261cfe759838213143ca3c2ad'
      @user.reset_auth_token = prc
      lambda do
        @user.determination_reset_auth_token
      end.should change(@user, :reset_auth_token).from(prc).to(nil)
    end
    it 'reset_auth_token_expires_atの値が更新されること' do
      time = Time.now
      @user.reset_auth_token_expires_at = time
      lambda do
        @user.determination_reset_auth_token
      end.should change(@user, :reset_auth_token_expires_at).from(time).to(nil)
    end
  end

  describe User, '#issue_activation_code' do
    before do
      @user = create_user(:tenant => @sg)
      @now = Time.local(2008, 11, 1)
      User.stub!(:activation_lifetime).and_return(2)
      Time.stub!(:now).and_return(@now)
    end
    it 'activation_tokenに値が入ること' do
      lambda do
        @user.issue_activation_code
      end.should change(@user, :activation_token)
    end
    it 'activation_token_expires_atが48時間後となること' do
      lambda do
        @user.issue_activation_code
      end.should change(@user, :activation_token_expires_at).from(nil).to(@now.since(48.hour))
    end
  end

  describe User, '#activate!' do
    it 'activation_tokenの値が更新されること' do
      activation_token = '6df711a1a42d110261cfe759838213143ca3c2ad'
      u = create_user(:tenant => @sg, :activation_token => activation_token, :status => 'UNUSED')
      u.password = ''
      lambda do
        u.activate!
      end.should change(u, :activation_token).from(activation_token).to(nil)
    end
    it 'activation_token_expires_atの値が更新されること' do
      time = Time.now
      u = create_user(:tenant => @sg, :activation_token_expires_at => time, :status => 'UNUSED')
      u.password = ''
      lambda do
        u.activate!
      end.should change(u, :activation_token_expires_at).from(time).to(nil)
    end
  end

  describe User, '#within_time_limit_of_activation_token' do
    before do
      @activation_token_expires_at = Time.local(2008, 11, 1, 0, 0, 0)
      @activation_token = 'activation_token'
    end
    describe 'activation_token_expires_atが期限切れの場合' do
      before do
        @user = create_user(:tenant => @sg, :activation_token => @activation_token, :activation_token_expires_at => @activation_token_expires_at )
        now = @activation_token_expires_at.since(1.second)
        Time.stub!(:now).and_return(now)
      end
      it 'falseが返ること' do
        @user.within_time_limit_of_activation_token?.should be_false
      end
    end
    describe 'activation_token_expires_atが期限切れではない場合' do
      before do
        @user = create_user(:tenant => @sg, :activation_token => @activation_token, :activation_token_expires_at => @activation_token_expires_at )
        now = @activation_token_expires_at.ago(1.second)
        Time.stub!(:now).and_return(now)
      end
      it 'trueが返ること' do
        @user.within_time_limit_of_activation_token?.should be_true
      end
    end
  end

  describe User, "#find_or_initialize_profiles" do
    before do
      @user = valid_user(:tenant => @sg)
      @user.save!
      @masters = (1..3).map{|i| create_user_profile_master(:tenant => @sg, :name => "master#{i}")}
      @master_1_id = @masters[0].id
      @master_2_id = @masters[1].id
    end
    describe "設定されていないプロフィールがわたってきた場合" do
      it "新規に作成される" do
        @user.find_or_initialize_profiles(@master_1_id.to_s => "ほげ").should_not be_empty
      end
      it "新規の値が設定される" do
        @user.find_or_initialize_profiles(@master_1_id.to_s => "ほげ")
        @user.user_profile_values.each do |values|
          values.value.should == "ほげ" if values.user_profile_master_id == @master_1_id
        end
      end
      it "保存されていないprofile_valueが返される" do
        profiles = @user.find_or_initialize_profiles(@master_1_id.to_s => "ほげ")
        profiles.first.should be_is_a(UserProfileValue)
        profiles.first.value.should == "ほげ"
        profiles.first.should be_new_record
      end
    end
    describe "既に存在するプロフィールがわたってきた場合" do
      before do
        @user.user_profile_values.create(:user_profile_master_id => @master_1_id, :value => "ふが")
      end
      it "上書きされたものが返される" do
        profiles = @user.find_or_initialize_profiles(@master_1_id.to_s => "ほげ")
        profiles.first.should be_is_a(UserProfileValue)
        profiles.first.value.should == "ほげ"
        profiles.first.should be_changed
      end
    end
    describe "新規の値と保存された値が渡された場合" do
      before do
        @user.user_profile_values.create(:user_profile_master_id => @master_1_id, :value => "ふが")
        @profiles = @user.find_or_initialize_profiles(@master_1_id.to_s => "ほげ", @master_2_id.to_s => "ほげほげ")
      end
      it "保存されていたmaster_idが1のvalueは上書きされていること" do
        @profiles.each do |profile|
          if profile.user_profile_master_id == @master_1_id
            profile.value.should == "ほげ"
          end
        end
      end
      it "新規のmaster_idが2のvalueは新しく作られていること" do
        @profiles.each do |profile|
          if profile.user_profile_master_id == @master_2_id
            profile.value.should == "ほげほげ"
          end
        end
      end
    end
    describe "マスタに存在する値がパラメータで送られてこない場合" do
      before do
        @user.user_profile_values.create(:user_profile_master_id => @master_1_id, :value => "ほげ")
        @profiles = @user.find_or_initialize_profiles({})
        @profile_hash = @profiles.index_by(&:user_profile_master_id)
      end
      it "空が登録されること" do
        @profile_hash[@master_1_id].value.should == ""
      end
      it "マスタの数だけprofile_valuesが返ってくること" do
        @profiles.size.should == @masters.size
      end
    end
  end

  describe User, "#openid_identifier" do
    it '現状map.resourceに存在しないパスを利用しており動作しない。修正する必要がある?'
#    before do
#      GlobalInitialSetting['host_and_port'] = 'test.host'
#      GlobalInitialSetting['protocol'] = 'http://'
#      @user = create_user(:tenant => @sg)
#    end
#    it "OPとして発行する OpenID identifier を返すこと" do
#      @user.openid_identifier.should == "http://test.host/id/a_user"
#    end
#    it "relative_url_rootが設定されている場合 反映されること" do
#      ActionController::Base.relative_url_root = "/skip"
#      @user.openid_identifier.should == "http://test.host/skip/id/a_user"
#    end
#    after do
#      ActionController::Base.relative_url_root = nil
#    end
  end

  describe User, '#within_time_limit_of_password?' do
    before do
      @user = create_user(:tenant => @sg)
      @enable_password_periodic_change_was = Admin::Setting.enable_password_periodic_change(@sg)
    end
    describe 'パスワード変更強制機能が有効な場合' do
      before do
        Admin::Setting.set_enable_password_periodic_change(@sg, 'true')
      end
      describe 'パスワードの有効期限切れ日が設定されている場合' do
        before do
          @user.password_expires_at = Time.local(2009, 3, 1, 0, 0, 0)
        end
        describe 'パスワード有効期限切れの場合' do
          before do
            now = Time.local(2009, 3, 1, 0, 0, 1)
            Time.stub!(:now).and_return(now)
          end
          it 'パスワード有効期限切れと判定されること' do
            @user.within_time_limit_of_password?.should be_false
          end
        end
        describe 'パスワード有効期限内の場合' do
          before do
            now = Time.local(2009, 3, 1, 0, 0, 0)
            Time.stub!(:now).and_return(now)
          end
          it 'パスワード有効期限内と判定されること' do
            @user.within_time_limit_of_password?.should be_true
          end
        end
      end
      describe 'パスワードの有効期限切れ日が設定されていない場合' do
        before do
          @user.password_expires_at = nil
        end
        it 'パスワード有効期限切れと判定されること' do
          @user.within_time_limit_of_password?.should be_nil
        end
      end

    end
    describe 'パスワード変更強制機能が無効な場合' do
      before do
        Admin::Setting.set_enable_password_periodic_change(@sg, 'false')
      end
      it 'パスワード有効期限内と判定されること' do
        @user.within_time_limit_of_password?.should be_true
      end
    end
    after do
      Admin::Setting.set_enable_password_periodic_change(@sg, @enable_password_periodic_change_was)
    end
  end

  describe User, '#to_s_log' do
    before do
      @user = create_user(:tenant => @sg)
    end
    it 'ログに出力する形式に整えられた文字列を返すこと' do
      @user.to_s_log('message').should == "message: {\"user_id\" => \"#{@user.id}\", \"email\" => \"#{@user.email}\"}"
    end
  end

  # ---------------------------------------- 
  # privateメソッドのテスト
  # ---------------------------------------- 

  describe User, 'password_required?' do
    before do
      @user = valid_user(:tenant => @sg)
    end
    describe 'パスワードモードの場合' do
      before do
        @sg.update_attribute :op_url, nil
      end
      describe 'パスワードが空の場合' do
        before do
          @user.password = ''
        end
        describe 'ユーザが利用中の場合' do
          before do
            @user.status = 'ACTIVE'
          end
          describe 'crypted_passwordが空の場合' do
            before do
              @user.crypted_password = ''
            end
            it '必要(true)と判定されること' do
              @user.send(:password_required?).should be_true
            end
          end
          describe 'crypted_passwordが空ではない場合' do
            before do
              @user.crypted_password = 'password'
            end
            it '必要ではない(false)と判定されること' do
              @user.send(:password_required?).should be_false
            end
          end
        end
        describe 'ユーザが利用中ではない場合' do
          before do
            @user.status = 'UNUSED'
          end
          it '必要ではない(false)と判定されること' do
            @user.send(:password_required?).should be_false
          end
        end
      end
      describe 'パスワードが空ではない場合' do
        before do
          @user.password = 'Password1'
        end
        it '必要(true)と判定されること' do
          @user.send(:password_required?).should be_true
        end
      end
    end
    describe 'パスワードモード以外の場合' do
      before do
        @sg.update_attribute :op_url, "http://localhost:3333/"
      end
      it '必要ではない(false)と判定されること' do
        @user.send(:password_required?).should be_false
      end
    end
  end

  describe User, '.auth_successed' do
    before do
      @user = create_user(:tenant => @sg)
    end
    it "検索されたユーザが返ること" do
      User.send(:auth_successed, @user).should == @user
    end
    describe 'ユーザがロックされている場合' do
      before do
        @user.should_receive(:locked?).and_return(true)
      end
      it 'last_authenticated_atが変化しないこと' do
        lambda do
          User.send(:auth_successed, @user)
        end.should_not change(@user, :last_authenticated_at)
      end
      it 'ログイン試行回数が変化しないこと' do
        lambda do
          User.send(:auth_successed, @user)
        end.should_not change(@user, :trial_num)
      end
    end
    describe 'ユーザがロックされていない場合' do
      before do
        @user.trial_num = 2
      end
      it "last_authenticated_atが現在時刻に設定されること" do
        time = Time.now
        Time.stub!(:now).and_return(time)
        lambda do
          User.send(:auth_successed, @user)
        end.should change(@user, :last_authenticated_at).to(time)
      end
      it 'ログイン試行回数が0になること' do
        lambda do
          User.send(:auth_successed, @user)
        end.should change(@user, :trial_num).to(0)
      end
    end
  end

  describe User, '.auth_failed' do
    before do
      @user = create_user(:tenant => @sg)
      @user_lock_trial_limit_was = Admin::Setting.user_lock_trial_limit(@sg)
      @enable_user_lock_was = Admin::Setting.enable_user_lock(@sg)
    end
    it 'nilが返ること' do
      User.send(:auth_failed, @user).should be_nil
    end
    describe 'ユーザがロックされていない場合' do
      before do
        @user.should_receive(:locked?).and_return(false)
      end
      describe 'ログイン試行回数が最大値未満の場合' do
        before do
          @user.trial_num = 2
          Admin::Setting.set_user_lock_trial_limit(@sg, 3)
        end
        describe 'ユーザロック機能が有効な場合' do
          before do
            Admin::Setting.set_enable_user_lock(@sg, 'true')
          end
          it 'ログイン試行回数が1増加すること' do
            lambda do
              User.send(:auth_failed, @user)
            end.should change(@user, :trial_num).to(3)
          end
        end
        describe 'ユーザロック機能が無効な場合' do
          before do
            Admin::Setting.set_enable_user_lock(@sg, 'false')
          end
          it 'ログイン試行回数が変化しないこと' do
            lambda do
              User.send(:auth_failed, @user)
            end.should_not change(@user, :trial_num)
          end
        end
      end
      describe 'ログイン試行回数が最大値以上の場合' do
        before do
          @user.trial_num = 3
          Admin::Setting.set_user_lock_trial_limit(@sg, 3)
        end
        describe 'ユーザロック機能が有効な場合' do
          before do
            Admin::Setting.set_enable_user_lock(@sg, 'true')
          end
          it 'ロックされること' do
            lambda do
              User.send(:auth_failed, @user)
            end.should change(@user, :locked).to(true)
          end
          it 'ロックした旨のログが出力されること' do
            @user.should_receive(:to_s_log).with('[User Locked]').and_return('user locked log')
            @user.logger.should_receive(:info).with('user locked log')
            User.send(:auth_failed, @user)
          end
        end
        describe 'ユーザロック機能が無効な場合' do
          before do
            Admin::Setting.set_enable_user_lock(@sg, 'false')
          end
          it 'ロック状態が変化しないこと' do
            lambda do
              User.send(:auth_failed, @user)
            end.should_not change(@user, :locked)
          end
          it 'ロックした旨のログが出力されないこと' do
            @user.stub!(:to_s_log).with('[User Locked]').and_return('user locked log')
            @user.logger.should_not_receive(:info).with('user locked log')
            User.send(:auth_failed, @user)
          end
        end
      end
    end
    describe 'ユーザがロックされている場合' do
      before do
        @user.should_receive(:locked?).and_return(true)
      end
      it 'ログイン試行回数が変化しないこと' do
        lambda do
          User.send(:auth_failed, @user)
        end.should_not change(@user, :trial_num)
      end
      it 'ロック状態が変化しないこと' do
        lambda do
          User.send(:auth_failed, @user)
        end.should_not change(@user, :locked)
      end
      it 'ロックした旨のログが出力されないこと' do
        @user.stub!(:to_s_log).with('[User Locked]').and_return('user locked log')
        @user.logger.should_not_receive(:info).with('user locked log')
        User.send(:auth_failed, @user)
      end
    end
    after do
      Admin::Setting.set_user_lock_trial_limit(@sg, @user_lock_trial_limit_was)
      Admin::Setting.set_enable_user_lock(@sg, @enable_user_lock_was)
    end
  end
end
