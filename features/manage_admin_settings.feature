Feature: 管理者による設定の管理
  管理者は、SKIPの設定を管理できる

  Background:
    Given   言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |admin  |
      |alice   |alice@test.com  |Password1  |skip         |true   |
    And "alice@test.com"でログインする

  Scenario: メールアドレスの表示を非表示/表示にする
    When "マイページ"にアクセスする
    And  "システムの管理"リンクをクリックする

    Then "メールアドレスを隠す"がチェックされていないこと

    When "メールアドレスを隠す"をチェックする
    And "保存"ボタンをクリックする

    Then flashメッセージに"保存しました。"と表示されていること
    And "メールアドレスを隠す"がチェックされていること

    When "alice@test.comのプロフィールページ"にアクセスする
    Then "メールアドレス"と表示されていないこと

    When "システムの管理"リンクをクリックする
    And "メールアドレスを隠す"のチェックを外す
    And "保存"ボタンをクリックする
    And "alice@test.comのプロフィールページ"にアクセスする

    Then "メールアドレス"と表示されていること
