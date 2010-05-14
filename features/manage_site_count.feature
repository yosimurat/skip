Feature: サイト情報
  ユーザはサイト情報でユーザ登録数などの統計データを確認出来る

  Background:
    Given 言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |alice   |alice@test.com  |Password1  |skip         |
    And "alice@test.com"でログインする

  Scenario: [登録ユーザ数]を確認出来る
    Given 現在の統計データを退避する

    When 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |jack    |jack@test.com  |Password1  |skip         |
    And 統計データを取得する

    Then "total_user_count"が"1"変化すること

    Given 現在の統計データを退避する

    When "jack@test.com"が退職する
    And 統計データを取得する

    Then "total_user_count"が"-1"変化すること

  Scenario: [本日のアクセス数]を確認出来る
    Given 現在の統計データを退避する

    When 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |jack    |jack@test.com   |Password1  |skip         |
    And "jack@test.com"でログインする
    And 統計データを取得する

    Then "today_user_count"が"1"変化すること

  Scenario: [総記事件数]を確認出来る
  Scenario: [本日の記事数]を確認出来る
  Scenario: [最近一ヶ月に記事、コメントを記入]を確認出来る
  Scenario: [直近一ヶ月のアクセス数平均]を確認出来る

  Scenario: [アクセスしたことがある人(10日間以内)]を確認出来る
    Given 現在の統計データを退避する

    When 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |jack    |jack@test.com  |Password1  |skip         |
    And "jack@test.com"でログインする
    And 統計データを取得する

    Then "active_users"が"1"変化すること

    Given 現在の統計データを退避する

    When "jack@test.com"が退職する
    And 統計データを取得する

    Then "active_users"が"-1"変化すること

  Scenario: [ブログを書いたことがある人](フォーラム除く、公開のみ)を確認出来る
    Given 現在の統計データを退避する
    When 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |jack    |jack@test.com   |Password1  |skip         |
      |dave    |dave@test.com   |Password1  |skip         |
      |carol   |carol@test.com  |Password1  |skip         |
    And 以下のブログを書く:
      |tenant_name  |user  |title                   |tag |contents|publication_type |
      |skip         |jack  |雑談スレ                |雑談|ほげほげ|全体に公開       |
      |skip         |dave  |雑談スレ                |雑談|ほげほげ|下書き           |
    And 以下のグループを作成する:
      |name     |owner_email      |
      |VimGroup |carol@test.com   |
    And 以下のフォーラムを書く:
      |tenant_name  |user   |group      |title            |tag |contents|publication_type|
      |skip         |carol  |VimGroup   |雑談スレ         |雑談|ほげほげ|全体に公開      |
    And "alice@test.com"でログインする
    And 統計データを取得する

    # フォーラム除く、公開のみ、自動投稿除く
    Then "write_users_all"が"1"変化すること
    # 非公開を含める
    And "write_users_with_pvt"が"2"変化すること
    # フォーラムを含める
    And "write_users_with_bbs"が"3"変化すること

    Given 現在の統計データを退避する

    When "jack@test.com"が退職する
    And 統計データを取得する

    Then "write_users_all"が"-1"変化すること
    And "write_users_with_pvt"が"-1"変化すること
    And "write_users_with_bbs"が"-1"変化すること

    When "dave@test.com"が退職する
    And 統計データを取得する

    Then "write_users_all"が"-1"変化すること
    And "write_users_with_pvt"が"-2"変化すること
    And "write_users_with_bbs"が"-2"変化すること

    When "carol@test.com"が退職する
    And 統計データを取得する

    Then "write_users_all"が"-1"変化すること
    And "write_users_with_pvt"が"-2"変化すること
    And "write_users_with_bbs"が"-3"変化すること

  Scenario: [コメントを書いたことがある人]を確認出来る
  Scenario: [プロフィール画像を変えている人]を確認出来る
