Feature: ユーザの初期プロフィール登録等
  ユーザは初期登録時、利用規約画面を表示し確認後、プロフィール情報を入力することで利用開始ができる

  Background:
    Given 言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |tenant_name  |status   |
      |alice   |alice@test.com  |skip         |UNUSED   |
    And   プロフィール項目が登録されていない

  Scenario: 未使用ユーザとして初期登録URLを発行できる
    Given メール機能を有効にする

    When  "ログインページ"にアクセスする
    And "Register your profile and start using SKIP"リンクをクリックする
    And "メールアドレス"に"alice@test.com"と入力する
    And "送信する"ボタンをクリックする

    Then flashメッセージに"ユーザ登録のためのURLを記載したメールをalice@test.com宛に送信しました。"と表示されていること
    And メールが"alice@test.com"宛に送信されていること

  Scenario: 初期登録URLからユーザのプロフィール登録を行なう
    When "alice@test.comのユーザ初期登録ページ"にアクセスする
    Then "利用規約"と表示されていること

    When "上記内容に同意する"ボタンをクリックする
    Then "利用者のプロフィール情報の登録"と表示されていること

    When "ユーザ登録"ボタンをクリックする

    Then "パスワードを入力してください。"と表示されていること
    And "確認パスワードを入力してください。"と表示されていること

    When "パスワード"に"Password1"と入力する
    And "確認パスワード"に"Password1"と入力する
    And "ユーザ登録"ボタンをクリックする
    Then "ようこそ"と表示されていること

  Scenario: 初期登録URLからアクセスし利用規約に同意しない
    When "alice@test.comのユーザ初期登録ページ"にアクセスする
    Then  "利用規約"と表示されていること

    When  "同意しない"ボタンをクリックする
    Then  "ログイン"と表示されていること
