Feature: ブックマークの管理
  ユーザは、ブックマークの作成/表示/更新/削除を行うことが出来る

  Background:
    Given 言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |alice   |alice@test.com  |Password1  |skip         |
      |jack    |jack@test.com   |Password1  |skip         |
    And "alice@test.com"でログインする

  Scenario: ブックマークを新規作成する
    When "ブックマークのURL入力ページ"にアクセスする
    And "URL"に"http://google.com"と入力する
    And "次へ"ボタンをクリックする

    Then "ブックマークの新規作成ページ"を表示していること

    When "タイトル"に"Google"と入力する
    And "公開する"を選択する
    And "タグ"に"検索エンジン"と入力する
    And "コメント"に"ブクマコメント"と入力する
    And "保存"ボタンをクリックする

    Then flashメッセージに"ブックマークを登録しました。"と表示されていること
