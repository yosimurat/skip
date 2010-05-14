Given /^以下のブログを書く:$/ do |entries_table|
  entries_table.hashes.each do |hash|
    tenant = Tenant.find_by_name(hash[:tenant_name]) || create_tenant(:name => hash[:tenant_name])
    user = tenant.users.find_by_name!(hash[:user])
    Given %!"#{user.email}"でログインする!
    Given %!"ブログを書く"リンクをクリックする!
    Given %!"タイトル"に"#{hash[:title]||"blog_title"}"と入力する!
    Given %!"タグ"に"#{hash[:tag]}"と入力する!
    Given %!"Wikiテキスト"を選択する!
    Given %!"board_entry_contents_hiki"に"#{hash[:content]||"test"}"と入力する!
    Given %!"#{hash[:publication_type]}"を選択する! if hash[:publication_type]
    Given %!"種類"から"#{hash[:aim_type]}"を選択する! if hash[:aim_type]
    Given %!"作成"ボタンをクリックする!
  end
end

Given /^"(.*)"で"(.*)"というタイトルのブログにアクセスする$/ do |email, title|
  Given %!"#{email}"でログインする!
  Given %!"#{title}の記事の表示ページ"にアクセスする!
end

Given /^以下のフォーラムを書く:$/ do |entries_table|
  @entries ||= []
  entries_table.hashes.each do |hash|
    tenant = Tenant.find_by_name(hash[:tenant_name]) || create_tenant(:name => hash[:tenant_name])
    user = tenant.users.find_by_name!(hash[:user])
    Given %!"#{user.email}"でログインする!
    group = Group.find_by_name!(hash[:group])
    Given %!"#{hash[:group]}グループのトップページ"にアクセスする!
    Given %!"記事を書く"リンクをクリックする!
    Given %!"タイトル"に"#{hash[:title]||"forum_title"}"と入力する!
    Given %!"タグ"に"#{hash[:tag]}"と入力する!
    Given %!"Wikiテキスト"を選択する!
    Given %!"board_entry_contents_hiki"に"#{hash[:content]||"test"}"と入力する!
    Given %!"#{hash[:publication_type]}"を選択する! if hash[:publication_type]
    Given %!"種類"から"#{hash[:aim_type]}"を選択する! if hash[:aim_type]
    Given %!"作成"ボタンをクリックする!
  end
end

Given /^"(.*)"で"(.*)"というタイトルのブログをブックマークする$/ do |email, title|
  Given %!"#{email}"でログインする!
  Given %!"#{title}の記事の表示ページ"にアクセスする!
  Given %!"ブックマークする"リンクをクリックする!
end

Given /^"([^\"]*)"という質問の公開状態を変更する$/ do |title|
  entry = BoardEntry.find_by_title(title)
  if entry
    visit(polymorphic_path([@current_tenant, entry.owner, entry], :action => :toggle_hide), :put)
  else
    raise ActiveRecord::RecordNotFound
  end
end
