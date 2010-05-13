Feature: 自分の管理
  メールアドレスなどを自分に関する情報を変更できるページ

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

  Scenario: メールアドレスの変更を申請する
    Given メール機能を有効にする
    And "alice@test.com"でログインする

    And "自分の管理"リンクをクリックする
    And "メールアドレス変更"リンクをクリックする
    And "applied_email_email"に"Test_User@example.com"と入力する
    And "申請"ボタンをクリックする

    Then flashメッセージに"メールアドレス変更の申請を受け付けました。メールをご確認ください。"と表示されていること
    And メールが"test_user@example.com"宛に送信されていること
