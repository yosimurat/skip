ActionController::Routing::Routes.draw do |map|
  map.resources :tenants, :only => [] do |tenant|
    tenant.root :controller => :mypages, :action => :index
    tenant.resource :mypage, :only => [],
      :collection => {
        :welcome => :get,
        :trace => :get,
        :entries => :get,
        :load_entries => :get,
        :entries_by_antenna => :get
      }
    tenant.resources :users, :new => {:agreement => :get}, :member => {:update_active => :put} do |user|
      user.resources :board_entries, :member => {:print => :get, :toggle_hide => :put, :toggle_read => :put}, :collection => {:preview => :post} do |board_entry|
        board_entry.resources :entry_trackbacks, :only => %w(destroy)
        board_entry.resource :board_entry_point, :only => [], :member => {:pointup => :put}
        board_entry.resources :board_entry_comments, :only => %w(create edit update destroy)
        board_entry.resources :entry_hide_operations, :only => %w(index)
      end
      user.resources :share_files, :member => {:download_history_as_csv => :get, :clear_download_history => :delete}, :collection => {:multi_create => :post}
      user.resources :pictures, :only => %w(show new create update destroy)
      user.resource :password, :only => %w(edit update)
      user.resource :applied_email, :only => %w(new create update), :member => {:complete => :get}
      user.resource :id, :only => %w(show edit create update)
      user.resource :message_unsubscribe, :only => %w(edit update)
      user.resource :customize, :only => %w(update)
      user.resources :chains, :collection => {:against => :get}
      user.resources :system_messages, :only => [:destroy]
      user.resources :notices, :only => %w(create destroy)
      # ユーザの参加グループ一覧のため
      user.resources :groups, :only => %w(index)
      user.resources :bookmarks, :only => %w(index)
    end
    tenant.resources :groups, :member => {:members => :get} do |group|
      group.resources :group_participations, :only => %w(new destroy), :collection => { :manage_members => :get, :manage_waiting_members => :get }, :member => { :add_admin_control => :put, :remove_admin_control => :put, :approve => :put, :disapprove => :delete }
      group.resources :users, :only => [] do |user|
        user.resources :group_participations, :only => %w(create)
      end
      group.resources :board_entries, :member => {:print => :get, :toggle_hide => :put, :toggle_read => :put}, :collection => {:preview => :post} do |board_entry|
        board_entry.resources :entry_trackbacks, :only => %w(destroy)
        board_entry.resource :board_entry_point, :only => [], :member => {:pointup => :put}
        board_entry.resources :board_entry_comments, :only => %w(create edit update destroy)
        board_entry.resources :entry_hide_operations, :only => %w(index)
      end
      group.resources :share_files, :member => {:download_history_as_csv => :get, :clear_download_history => :delete}, :collection => {:multi_create => :post}
      group.resources :notices, :only => %w(create destroy)
    end
    tenant.resources :share_files, :only => %w(index show)
    tenant.resources :board_entries, :only => %w(index show), :collection => {:be_read => :post, :be_unread => :post}
    tenant.resources :bookmarks, :only => %w(index show new create edit update), :collection => {:new_without_bookmarklet => :get, :new_url => :get, :load_title => :get}, :member => {:edit_without_bookmarklet => :get} do |bookmark|
      bookmark.resources :bookmark_comments, :only => %w(destroy)
    end
    tenant.resource :invitations, :only => %w(new create)
    tenant.resource :statistics, :only => %w(show), :member => { :load_calendar => :get, :ado_current_statistics => :get, :ado_statistics_history => :get }
    tenant.resources :ids, :only => :show
    tenant.resource :search, :only => [], :member => { :full_text_search => :get }
    tenant.logo '/logos/:id/:style/:basename.:extension', :controller => :logos, :action => :show
    tenant.resources :documents, :only => %w(show)
  end

  map.namespace "admin" do |admin_map|
    admin_map.resources :tenants, :only => [] do |tenant|
      tenant.root :controller => 'settings', :action => 'index', :tab => 'main'
      tenant.resources :board_entries, :only => [:index, :show, :destroy], :member => {:close => :put} do |board_entry|
        board_entry.resources :board_entry_comments, :only => [:index, :destroy]
      end
      tenant.resources :share_files, :only => [:index, :destroy], :member => [:download]
      tenant.resources :bookmarks, :only => [:index, :show, :destroy] do |bookmark|
        bookmark.resources :bookmark_comments, :only => [:index, :destroy]
      end
      tenant.resources :users, :new => [:import, :import_confirmation, :first], :member => [:change_uid, :create_uid, :issue_activation_code, :issue_password_reset_code], :collection => [:lock_actives, :reset_all_password_expiration_periods, :issue_activation_codes] do |user|
  #        user.resources :openid_identifiers, :only => [:edit, :update, :destroy]
        user.resource :user_profile
        user.resource :pictures, :only => %w(new create)
      end
      tenant.resources :pictures, :only => %w(index show destroy)
      tenant.resources :groups, :only => [:index, :show, :destroy] do |group|
        group.resources :group_participations, :only => [:index, :destroy]
      end
      tenant.resources :masters, :only => [:index]
      tenant.resources :group_categories
      tenant.resources :user_profile_master_categories
      tenant.resources :user_profile_masters
      tenant.settings_update_all 'settings/:tab/update_all', :controller => 'settings', :action => 'update_all'
      tenant.settings_ado_feed_item 'settings/ado_feed_item', :controller => 'settings', :action => 'ado_feed_item'
      tenant.settings 'settings/:tab', :controller => 'settings', :action => 'index', :defaults => { :tab => '' }

      tenant.resources :documents, :only => %w(edit update), :member => {:revert => :put}

      tenant.resources :images, :only => %w(index)
      tenant.resource :logos, :only => %w(update destroy)
    end
  end

  map.namespace "apps" do |app|
    app.resources :events, :member => {:attend => :post, :absent => :post}, :collection => { :recent => :get }, :except => [:destroy] do |event|
      event.resources :attendees, :only => [:update]
    end
    app.resource :javascripts, :only => [], :member => {:application => :get}
  end

  map.namespace "feed" do |feed_map|
    feed_map.resources :tenants, :only => [] do |tenant|
      tenant.resources :board_entries, :only => %w(index), :collection => {:questions => :get, :timelines => :get, :popular_blogs => :get}
      tenant.resources :bookmarks, :only => %w(index)
    end
  end

  map.resource :platform, :only => %(show), :member => {
    :login => :any,
    :logout => :any,
    :activate => :any,
    :forgot_password => :any,
    :reset_password => :any,
    :signup => :any,
    :require_login => :get
  }

  map.resource :services, :only => [], :member => { :search_conditions => :get }

  map.root :controller => :platforms, :action => :show

  map.with_options :controller => 'server' do |server|
    server.formatted_server 'server.:format', :action => 'index'
    server.server 'server', :action => 'index'
    server.cancel 'server/cancel', :action => 'cancel'
    server.proceed 'server/proceed', :action => 'proceed'
  end

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
