#Given /^"([^\"]*)"で"([^\"]*)"というグループを作成する$/ do |user, gid|
#  unless Group.find_by_gid(gid)
#    Given %!"#{user}"でログインする!
#    Given %!"グループの新規作成ページ"にアクセスする!
#    Given %!"#{"グループID"}"に"#{gid}"と入力する!
#    Given %!"#{"名称"}"に"テストグループ"と入力する!
#    Given %!"#{"説明"}"に"説明"と入力する!
#    Given %!"#{"作成"}"ボタンをクリックする!
#  end
#end
#
#When /^"([^\"]*)"で"([^\"]*)"グループのサマリページを開く$/ do |user, gid|
#  Given %!"#{user}"でログインする!
#  visit url_for(:controller => 'group', :gid => gid, :action => 'show')
#end
#
Given /^以下のグループを作成する:$/ do |table|
  table.hashes.each do |hash|
    owner = User.find_by_email!(hash[:owner_email])
    Given %!"#{hash[:owner_email]}"でログインする!
    if @current_tenant.group_categories.empty?
      create_group_category(:tenant => @current_tenant)
    end
    Given %!"グループの新規作成ページ"にアクセスする!
    Given %!"#{"名称"}"に"#{hash[:name] ? hash[:name] : 'グループ'}"と入力する!
    Given %!"#{"説明"}"に"#{hash[:desc] ? hash[:desc] : '説明'}"と入力する!
    Given %!"#{"参加するのにオーナーの承認が必要ですか？"}"から"#{hash[:waiting] == 'true' ? 'はい' : 'いいえ'}"を選択する!
    Given %!"#{"作成"}"ボタンをクリックする!
  end
end

Given /^"([^\"]*)"が"([^\"]*)"グループに参加する$/ do |email, group_name|
  Given %!"#{email}"でログインする!
  Given %!"#{group_name}グループのトップページ"にアクセスする!
  Given %!"参加する"リンクをクリックする!
end

Given /^"([^\"]*)"が"([^\"]*)"グループを退会する$/ do |email, group_name|
  Given %!"#{email}"でログインする!
  Given %!"#{group_name}グループのトップページ"にアクセスする!
  Given %!"退会する"リンクをクリックする!
end

### TODO 無理やりすぎる。change_participationをリファクタしてからここも書き直す
#Given /^"([^\"]*)"で"([^\"]*)"の"([^\"]*)"グループへの参加を承認する$/ do |admin_email, target_email, group_name|
#  Given %!"#{admin_email}"でログインする!
#  group = @current_tenant.groups.find_by_name!(group_name)
#  Given %!"#{group_name}
#  target_user = @current_tenant.users.find_by_email!(target_email)
#  gp = group.group_participations.find_by_user_id(target_user.id)
##  visit( url_for({
##      :controller => 'group',
##      :gid => gid,
##      :action => 'change_participation',
##      :participation_state => {gp.id.to_s => true},
##      :submit_type => 'permit'
##  }), :post)
#end
#
#Given /^"([^\"]*)"で"([^\"]*)"の"([^\"]*)"グループへの参加を棄却する$/ do |admin_uid, target_uid, gid|
#  Given %!"#{admin_uid}"でログインする!
#  group = Group.find_by_gid(gid)
#  user = User.find_by_uid(target_uid)
#  gp = group.group_participations.find_by_user_id(user.id)
#  visit( url_for({
#      :controller => 'group',
#      :gid => gid,
#      :action => 'change_participation',
#      :participation_state => {gp.id.to_s => true},
#      :submit_type => 'reject'
#  }), :post)
#end
#
Given /^"([^\"]*)"で"([^\"]*)"を"([^\"]*)"グループへ強制参加させる$/ do |admin_email, target_name, group_name|
  Given %!"#{admin_email}"でログインする!
  Given %!"#{group_name}グループのトップページ"にアクセスする!
  Given %!"管理"リンクをクリックする!
  Given %!"参加者管理"リンクをクリックする!
  Given %!"新規参加者の作成"リンクをクリックする!
  Given %!"名前"に"#{target_name}"と入力する!
  Given %!"#contents_right"中の"検索"ボタンをクリックする!
  Given %!"参加者に追加"リンクをクリックする!
end

Given /^"([^\"]*)"で"([^\"]*)"を"([^\"]*)"グループから強制退会させる$/ do |admin_email, target_email, group_name|
  Given %!"#{admin_email}"でログインする!
  group = @current_tenant.groups.find_by_name(group_name)
  target_user = @current_tenant.users.find_by_email!(target_email)
  group_participation = group.group_participations.find_by_user_id!(target_user.id)
  visit(polymorphic_path([@current_tenant, group, group_participation]), :delete)
end
