Feature: イベントの管理
  ユーザがイベントを作成/更新できる

  Background:
    Given   言語は"ja-JP"
    And     "a_user"でログインする

  Scenario: 公開イベントを作成する
    Given   "イベントの新規作成ページ"にアクセスする

    When    "Name of Event"に"アリスイベント"と入力する
    And     "Description"に"アリス専用"と入力する
    And     "Period of Event"に"2時間"と入力する
    And     "Anyone"を選択する
    And     "作成"ボタンをクリックする

    Then    I should see "Event was created successfully"
    #Then    flashメッセージに"イベントが正しく作成されました。"と表示されていること
    And     "Attend this event"と表示されていないこと
    And     "Absent this event"と表示されていること
    And     "[編集]"と表示されていること

  Scenario: 招待イベントを作成する
    Given   "イベントの新規作成ページ"にアクセスする

    When    "Name of Event"に"アリスイベント"と入力する
    And     "Description"に"アリス専用"と入力する
    And     "Period of Event"に"2時間"と入力する
    And     "Only invited members"を選択する
    And     "publication_symbols_value"に"uid:0000"と入力する
    And     "作成"ボタンをクリックする

    Then    I should see "Event was created successfully"
    #Then    flashメッセージに"イベントが正しく作成されました。"と表示されていること
    And     "Attend this event"と表示されていないこと
    And     "Absent this event"と表示されていること
    And     "[編集]"と表示されていること

  Scenario: 公開イベントに参加する
  Scenario: 招待イベントに参加する
  Scenario: 招待イベントに参加しない


