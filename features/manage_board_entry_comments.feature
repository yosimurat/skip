Feature: コメントの管理
  ユーザは、記事にコメントをすることができる

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
    And 以下のブログを書く:
      |tenant_name   |user   |title            |
      |skip          |alice  |2009-01-01の日記 |

  Scenario: ユーザとして空のコメントが登録できない
    When "jack@test.com"でログインする
    And "2009-01-01の日記の記事の表示ページ"にアクセスする
    And "コメントを書く"に""と入力する
    And "書き込み"ボタンをクリックする
    Then "保存に失敗しました。"と表示されること

  Scenario: ユーザとして妥当なコメントが登録できる
    When "jack@test.com"でログインする
    And "2009-01-01の日記の記事の表示ページ"にアクセスする
    And "コメントを書く"に"コメント"と入力する
    And "書き込み"ボタンをクリックする
    Then "新着"と表示されること
    And "コメント"と表示されること

  Scenario: ユーザとしてGoodJobポイントを追加できる
    When "jack@test.com"でログインする
    And "2009-01-01の日記の記事の表示ページ"にアクセスする
    And "0 GoodJob"ボタンをクリックする
    Then "1 GoodJob"と表示されること
