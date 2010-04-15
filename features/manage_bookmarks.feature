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

    Then "ブックマーク一覧ページ"を表示していること
    And flashメッセージに"ブックマークを登録しました。"と表示されていること

  Scenario: ブックマークコメントを追加する
    Given 以下のブックマークを作成する:
      |url                  |title    |tenant_name  |
      |http://google.co.jp  |Google   |skip         |
    And 以下のブックマークコメントを作成する:
      |comment            |public   |tag_strings    |bookmark_url           |user_name  |
      |Gooooogle          |true     |foo,bar        |http://google.co.jp    |alice      |
    And "jack@test.com"でログインする

    When "ブックマークのURL入力ページ"にアクセスする
    And "URL"に"http://google.co.jp"と入力する
    And "次へ"ボタンをクリックする

    Then "http://google.co.jpのブックマークの編集ページ"を表示していること

    When "タイトル"に"グーグル"と入力する
    And "公開する"を選択する
    And "タグ"に"サーチエンジン"と入力する
    And "コメント"に"jackのブクマコメント"と入力する
    And "保存"ボタンをクリックする

    Then "ブックマーク一覧ページ"を表示していること
    And flashメッセージに"ブックマークを更新しました。"と表示されていること

  Scenario: ブックマークを更新する
    Given 以下のブックマークを作成する:
      |url                  |title    |tenant_name  |
      |http://google.co.jp  |Google   |skip         |
    And 以下のブックマークコメントを作成する:
      |comment            |public   |tag_strings    |bookmark_url           |user_name  |
      |Gooooogle          |true     |foo,bar        |http://google.co.jp    |alice      |
    And "alice@test.com"でログインする

    When "ブックマークのURL入力ページ"にアクセスする
    And "URL"に"http://google.co.jp"と入力する
    And "次へ"ボタンをクリックする

    Then "http://google.co.jpのブックマークの編集ページ"を表示していること

    When "タイトル"に"グーグル"と入力する
    And "公開する"を選択する
    And "タグ"に"サーチエンジン"と入力する
    And "コメント"に"jackのブクマコメント"と入力する
    And "保存"ボタンをクリックする

    Then "ブックマーク一覧ページ"を表示していること
    And flashメッセージに"ブックマークを更新しました。"と表示されていること

  Scenario: ブックマークを削除する
    Given 以下のブックマークを作成する:
      |url                  |title    |tenant_name  |
      |http://google.co.jp  |Google   |skip         |
    And 以下のブックマークコメントを作成する:
      |comment            |public   |tag_strings    |bookmark_url           |user_name  |
      |Gooooogle          |true     |foo,bar        |http://google.co.jp    |alice      |
    And "alice@test.com"でログインする

    When "http://google.co.jpのブックマークの表示ページ"にアクセスする
    And "削除"リンクをクリックする

    Then "ブックマーク一覧ページ"を表示していること
    And flashメッセージに"該当するデータはありませんでした。"と表示されていること
