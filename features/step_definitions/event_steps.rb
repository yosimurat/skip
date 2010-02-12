Given /^"([^\"]*)"で公開イベントを作成する$/ do |user|
  Given %!"#{user}"でログインする!
  Given %!"イベントの新規作成ページ"にアクセスする!
  Given %!"#{"Name of Event"}"に"テストイベント"と入力する!
  Given %!"#{"Description"}"に"説明"と入力する!
  Given %!"#{"Period of Event"}"に"2時間"と入力する!
  Given %!"Anyone"を選択する!
  Given %!"#{"作成"}"ボタンをクリックする!
  Given %!ログアウトする!
end

