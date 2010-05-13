Feature: 紹介文の管理
  ユーザが任意のユーザに対する紹介文を作成/更新できる

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

  Scenario: 紹介文を作成/更新する
    When "jack@test.com"でログインする
    And "alice@test.comのプロフィールページ"にアクセスする
    And "みんなに紹介する"リンクをクリックする
    And "作成"ボタンをクリックする
    Then "紹介文を入力してください。"と表示されること

    When "chain_comment"に"アリスを紹介します。"と入力する
    And "作成"ボタンをクリックする

    Then flashメッセージに"紹介文を作成しました"と表示されていること
    And "アリスを紹介します。"と表示されていること

    When "alice@test.com"でログインする

    Then "あなたの紹介文が追加されました！"と表示されていること

  Scenario: 紹介文を更新する
    Given 以下の紹介文を作成する:
      |from_user        |comment      |to_user        |
      |jack@test.com    |Aliceです。  |alice@test.com |

    When "jack@test.com"でログインする
    And "alice@test.comのプロフィールページ"にアクセスする
    And "紹介文の変更"リンクをクリックする
    And "chain_comment"に"アリスを宜しくお願いします。"と入力する
    And "更新"ボタンをクリックする

    Then flashメッセージに"紹介文を更新しました"と表示されていること
    And "アリスを宜しくお願いします。"と表示されていること

  Scenario: 紹介文を削除する
    Given 以下の紹介文を作成する:
      |from_user        |comment      |to_user        |
      |jack@test.com    |Aliceです。  |alice@test.com |

    When "jack@test.com"でログインする
    And "alice@test.comのプロフィールページ"にアクセスする
    And "紹介文の変更"リンクをクリックする
    And "[削除]"リンクをクリックする

    Then flashメッセージに"紹介文を削除しました"と表示されていること
