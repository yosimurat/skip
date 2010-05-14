Feature: 管理者がプロフィール画像を管理する
  管理者としてプロフィール画像の管理を行いたい

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

  Scenario: プロフィール画像一覧を初期表示する
    When "マイページ"にアクセスする
    And "システムの管理"リンクをクリックする
    And "データ管理"リンクをクリックする

    When "プロフィール画像"リンクをクリックする

    Then "プロフィール画像一覧"と表示されていること
