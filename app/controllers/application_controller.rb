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

require 'tempfile'

class ApplicationController < ActionController::Base
  include OpenidServerSystem
  include ExceptionNotifiable if GlobalInitialSetting['exception_notifier']['enable']

  helper :all

  layout 'layout'

  filter_parameter_logging :password

  protect_from_forgery

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    if request.env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
      render :text => _('Invalid session. You need to log in again.'), :status => :bad_request
    else
      redirect_to_with_deny_auth
    end
  end

  before_filter :sso, :login_required, :valid_tenant_required

  init_gettext "skip" if defined? GetText

  helper_method :scheme, :endpoint_url, :identifier, :checkid_request, :extract_login_from_identifier, :logged_in?, :current_user, :current_target_user, :current_target_group, :current_target_owner, :current_participation, :event_enabled?, :current_tenant, :root_url, :current_target_bookmark, :bookmark_enabled?
protected
  include InitialSettingsHelper

  def remove_system_message
    if params[:system_message_id] && sm = current_user.system_messages.find_by_id(params[:system_message_id])
      sm.destroy
    end
  end

  def setup_custom_cookies(custom)
    cookies[:editor_mode] = {
      :value => custom.editor_mode,
      :expires => 1.month.from_now
    }
  end

  def logged_in?
    !!current_user
  end

  def current_user
    @current_user ||= (login_from_session || login_from_cookie)
  end

  def current_user=(user)
    if user
      session[:auth_session_token] = user.update_auth_session_token!
      setup_custom_cookies(user.custom)
      @current_user = user
    else
      @current_user = nil
    end
  end

  def current_target_user
    @current_target_user ||= User.find_by_tenant_id_and_id(current_tenant, (params[:controller] == 'users' ? params[:id] : params[:user_id]))
  end

  def current_target_group
    @current_target_group ||= Group.find_by_tenant_id_and_id(current_tenant, (params[:controller] == 'groups' ? params[:id] : params[:group_id]))
  end

  def current_target_owner
    @current_target_owner ||= (current_target_user || current_target_group)
  end

  def target_user_required
    unless current_target_user
      render_404
      return false
    end
  end

  def target_group_required
    unless current_target_group
      render_404
      return false
    end
  end

  def owner_required
    unless current_target_owner
      render_404
      return false
    end
  end

  def current_participation
    @current_participation ||= current_target_group.group_participations.find_by_user_id(current_user.id) if current_target_group
  end

  def current_tenant
    @current_tenant ||= Tenant.find_by_id(params[:tenant_id])
  end

  def current_target_bookmark
    @current_target_bookmark ||= Bookmark.find_by_tenant_id_and_id(current_tenant, (params[:controller] == 'bookmarks' ? params[:id] : params[:bookmark_id]))
  end

  def login_required options = {}
    options = {:allow_unused_user => false, :trace_access => true}.merge!(options)
    unless logged_in?
      if request.env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
        render :text => _('Session expired. You need to log in again.'), :status => :bad_request
      else
        if request.url == root_url
          redirect_to [current_tenant, :platform]
        else
          redirect_to polymorphic_url(:platform, :action => :require_login, :return_to => URI.decode(request.url))
        end
      end
      false
    else
      if current_user.active? || options[:allow_unused_user]
        if options[:trace_access]
          # ログのリクエスト情報に、ユーザ情報を加える（情報漏えい事故発生時のトレーサビリティを確保)
          logger.info(current_user.to_s_log('[Log for inspection]'))
          if access = current_user.user_access
            access.update_attribute(:last_access, Time.now)
          end
        end
        # Settingのキャッシュをチェックする
        Admin::Setting.check_cache
        true
      else
        redirect_to current_user.retired? ? logout_platform_url(:message => 'retired') : new_tenant_user_url(current_tenant)
        false
      end
    end
  end

  def valid_tenant_required
    unless current_tenant and current_user.tenant.id == current_tenant.id
      redirect_to root_url
    end
  end

  def redirect_to_with_deny_auth(url = root_url)
    flash[:warn] = _('Operation unauthorized.')
    redirect_to url
  end

  # exception_notification用にオーバーライド
  def rescue_action_in_public ex
    case ex
    when ActionController::UnknownController, ActionController::UnknownAction,
      ActionController::RoutingError, ActiveRecord::RecordNotFound
      render_404
    else
      logger.error ex
      ex.backtrace.each { |line| logger.error line}

      render :template => "system/500" , :status => :internal_server_error

      if GlobalInitialSetting['exception_notifier']['enable']
        deliverer = self.class.exception_data
        data = case deliverer
          when nil then {}
          when Symbol then send(deliverer)
          when Proc then deliverer.call(self)
        end

        ExceptionNotifier.deliver_exception_notification(ex, self, request, data)
      end
    end
  end

  def render_404
    respond_to do |format|
      format.html { render :file => File.join(RAILS_ROOT, 'public', '404.html'), :status => :not_found }
      format.all { render :nothing => true, :status => :not_found }
    end
    true
  end

  # 本番環境(リバースプロキシあり)では、リモートからのリクエストでもリバースプロキシで、
  # ハンドリングされるので、ローカルからのリクエストとRailsが認識していう場合がある。
  # (lighttpd の mod_extfoward が根本の問題)
  # そもそも、enviromentの設定でどのエラー画面を出すかの設定は可能で、本番環境で詳細な
  # エラー画面を出す必要は無いので、常にリモートからのアクセスと認識させるべき。
  # なので、rescue.rb local_requestメソッドをオーバーライドしている。
  def local_request?
    false
  end

  # restful_authenticationが生成するlib/authenticated_system.rbから「次回から自動的にログイン」機能
  # に必要な箇所を持ってきた。
  def login_from_session
    User.find_by_auth_session_token(session[:auth_session_token]) if session[:auth_session_token]
  end

  def login_from_cookie
    user = cookies[:auth_token] && User.find_by_remember_token(cookies[:auth_token])
    if user && user.remember_token?
      handle_remember_cookie! false
      user
    end
  end

  #
  # Remember_me Tokens
  #
  # Cookies shouldn't be allowed to persist past their freshness date,
  # and they should be changed at each login

  # Cookies shouldn't be allowed to persist past their freshness date,
  # and they should be changed at each login

  def valid_remember_cookie?
    return nil unless @current_user
    (@current_user.remember_token?) &&
      (cookies[:auth_token] == @current_user.remember_token)
  end

  # Refresh the cookie auth token if it exists, create it otherwise
  def handle_remember_cookie! new_cookie_flag
    return unless @current_user
    case
    when valid_remember_cookie? then @current_user.refresh_token # keeping same expiry date
    when new_cookie_flag        then @current_user.remember_me
    else                             @current_user.forget_me
    end
    send_remember_cookie!
  end

  def kill_remember_cookie!
    cookies.delete :auth_token
  end

  def logout_killing_session!(keeping = [])
    h = Hash[*keeping.inject([]) do |result, item|
               result << item << session[item] if session[item]
               result
             end
            ]
    @current_user.forget_me if @current_user.is_a? User
    kill_remember_cookie!
    reset_session
    h.each do |key, val|
      session[key] = val
    end
  end

  def send_remember_cookie!
    cookies[:auth_token] = {
      :value   => @current_user.remember_token,
      :expires => @current_user.remember_token_expires_at }
  end

  # ファイルアップロード時の共通チェック
  def valid_upload_file? file, max_size = 209715200
    file.is_a?(ActionController::UploadedFile) && file.size > 0 && file.size < max_size
  end

  # 複数ファイルアップロード時の共通チェック
  def valid_upload_files? files, max_size = 209715200
    files.each do |key, file|
      return false unless valid_upload_file?(file, max_size)
    end
    return true
  end

  def scheme
    GlobalInitialSetting['protocol']
  end

  def endpoint_url
    server_url(:protocol => scheme)
  end

  def identifier(user, options = {})
    tenant_id_url(user.tenant, options.update(:id => user.code, :protocol => scheme))
  end

  def checkid_request
    unless @checkid_request
      req = openid_server.decode_request(current_openid_request.parameters) if current_openid_request
      @checkid_request = req.is_a?(OpenID::Server::CheckIDRequest) ? req : false
    end
    @checkid_request
  end

  def current_openid_request
    @current_openid_request ||= OpenIdRequest.find_by_token(session[:request_token]) if session[:request_token]
  end

  # TODO: openid_identifierからユーザを特定して、emailを算出するメソッドに変更する
  def extract_login_from_identifier(openid_url)
    openid_url.gsub(identifier(''), '')
  end

  def event_enabled?
    (simple_apps = Admin::Setting.simple_apps(current_tenant)) && simple_apps['event'] && simple_apps['event']['enable']
  end

  def root_url_with_logged_in
    if logged_in?
      tenant_root_url(current_user.tenant)
    else
      root_url_without_logged_in
    end
  end
  alias_method_chain :root_url, :logged_in

  def bookmark_enabled?
    Admin::Setting.enable_bookmark_feature(current_tenant)
  end

  def require_bookmark_enabled
    redirect_to root_url unless bookmark_enabled?
  end

  private
  def sso
    if login_mode?(:fixed_rp) and !logged_in?
      if request.env['HTTP_X_REQUESTED_WITH'] == 'XMLHttpRequest'
        render :text => _('Session expired. You need to log in again.'), :status => :bad_request
      else
        redirect_to login_platform_url(:openid_url => current_tenant.op_url, :return_to => URI.encode(request.url))
      end
      return false
    end
    true
  end

  def msie?(version = 6)
    !!(request.env["HTTP_USER_AGENT"]["MSIE #{version}"])
  end
end
