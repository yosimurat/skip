Feature: 管理者がユーザを管理する
  管理者としてユーザを管理する

  Background:
    Given  言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |admin  |
      |alice   |alice@test.com  |Password1  |skip         |true   |
    And "alice@test.com"でログインする

  Scenario: 新規のユーザを未使用ユーザとして登録する
    When "マイページ"にアクセスする
    And "システムの管理"リンクをクリックする
    And "ユーザ管理"リンクをクリックする

    When "管理画面のユーザ一覧ページ"にアクセスする

    When "新規ユーザの作成"リンクをクリックする
    And "名前"に"新規 一郎"と入力する
    And "メールアドレス"に"newuser@example.com"と入力する
    And "作成"ボタンをクリックする

    Then flashメッセージに"登録しました。"と表示されていること
