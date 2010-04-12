Feature: 新着通知の管理
  ユーザは、新着通知にユーザやグループを登録、管理できる

  Background:
    Given   言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |alice   |alice@test.com  |Password1  |skip         |
      |jack    |jack@test.com   |Password1  |skip         |
    And "alice@test.com"でログインする

  Scenario: ユーザを新着に追加/停止する
    When "jack@test.comのプロフィールページ"にアクセスする
    And "新着時に通知"リンクをクリックする

    Then "新着通知を止める"と表示されていること

    When "新着通知を止める"リンクをクリックする

    Then "新着時に通知"と表示されていること

  Scenario: グループを新着に追加/停止する

