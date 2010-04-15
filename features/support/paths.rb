module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    when /ログインページ/
      platform_url

    when /^(.*)テナントのマイページ$/
      tenant_root_path(Tenant.find_by_name($1))

    when /^(.*)のプロフィールページ$/
      u = @current_tenant.users.find_by_email($1)
      polymorphic_path([@current_tenant, u])

    when /^ブックマーク一覧ページ$/
      polymorphic_path([@current_tenant, :bookmarks])

    when /^ブックマークのURL入力ページ$/
      polymorphic_path([@current_tenant, :bookmarks], :action => :new_url)

    when /^ブックマークの新規作成ページ$/
      polymorphic_path([@current_tenant, :bookmarks], :action => :new_without_bookmarklet)

    when /^(.*)のブックマークの編集ページ$/
      b = @current_tenant.bookmarks.find_by_url($1)
      polymorphic_path([@current_tenant, b], :action => :edit_without_bookmarklet)

    when /^(.*)のブックマークの表示ページ$/
      b = @current_tenant.bookmarks.find_by_url($1)
      polymorphic_path([@current_tenant, b])

    when /管理ページ/
      '/admin/'

    when /グローバルのグループ一覧ページ/
      '/groups/'

    when /プロフィール画像一覧/
      admin_pictures_path

    when /グループの新規作成ページ/
      url_for(:controller => 'groups', :action => 'new')

    when /^(.*)グループのトップページ$/
      url_for(:controller => "/group", :action => "show", :gid => $1)

    when /管理画面のユーザ一覧/
      admin_users_path


    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
