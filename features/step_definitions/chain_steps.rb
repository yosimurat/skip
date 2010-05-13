Given /^以下の紹介文を作成する:$/ do |table|
  table.hashes.each do |hash|
    from_user = User.find_by_email(hash[:from_user])
    to_user = User.find_by_email(hash[:to_user])
    Given %!"#{hash[:from_user]}"でログインする!
    Given %!"#{hash[:to_user]}のプロフィールページ"にアクセスする!
    Given %!"みんなに紹介する"リンクをクリックする!
    Given %!"chain_comment"に"#{hash[:comment]}"と入力する!
    Given %!"作成"ボタンをクリックする!
  end
end
