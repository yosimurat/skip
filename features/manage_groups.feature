Feature: グループの管理
  グループは、SKIPのグループを管理できる

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
      |dave    |dave@test.com   |Password1  |skip         |
    And 以下のグループカテゴリを作成する:
      |tenant_name  |code     |name     |
      |skip         |work     |仕事     |

  Scenario: ユーザとしてグループの新規作成に成功する
    When "alice@test.com"でログインする
    And "グローバルのグループ一覧ページ"にアクセスする
    And "グループの作成"リンクをクリックする
    And "名称"に"アリスグループ"と入力する
    And "説明"に"アリス専用"と入力する
    And "全体に公開"を選択する
    And "投稿時にメールも送信する"をチェックする
    And "作成"ボタンをクリックする

    Then flashメッセージに"グループが正しく作成されました。"と表示されていること

  Scenario: ユーザとして承認が不要なグループに参加することが出来る
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |

    When "jack@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする
    And "参加する"リンクをクリックする

    Then flashメッセージに"グループに参加しました。"と表示されていること

  Scenario: ユーザとして承認が必要なグループに参加することが出来る
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |true     |

    When "jack@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする
    And "参加する"リンクをクリックする

    Then flashメッセージに"参加申し込みをしました。承認されるのをお待ちください。"と表示されていること

  Scenario: ユーザとして参加中のグループから退会することが出来る
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する

    When "jack@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする
    And "退会する"リンクをクリックする

    Then flashメッセージに"退会しました。"と表示されていること

  Scenario: グループ管理者として参加申請中のユーザを承認することが出来る
  Scenario: グループ管理者として参加申請中のユーザを棄却することが出来る

  Scenario: グループ管理者としてユーザを強制参加させることが出来る
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
      |Rails        |dave@test.com    |false    |

    When "dave@test.com"でログインする
    And "Railsグループのトップページ"にアクセスする
    And "管理"リンクをクリックする
    And "参加者管理"リンクをクリックする
    And "新規参加者の作成"リンクをクリックする
    And "名前"に"jack"と入力する
    And "#contents_right"中の"検索"ボタンをクリックする
    And "参加者に追加"リンクをクリックする

    Then flashメッセージに"jackさんを参加者に追加しました。"と表示されていること

  Scenario: グループ管理者としてユーザを強制退会させることが出来る
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する

    When "alice@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする
    And "管理"リンクをクリックする
    And "参加者管理"リンクをクリックする
    And "[強制退会させる]"リンクをクリックする

    Then flashメッセージに"jackさんをこのグループの参加者から削除しました。"と表示されていること

  Scenario: グループ未参加時のアクション表示
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |

    When "jack@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする

    Then "参加する"と表示されていること
    And "新着時に通知"と表示されていること
    And "記事を書く"と表示されていないこと
    And "質問を書く"と表示されていないこと
    And "ファイルをアップ"と表示されていないこと
    And "退会する"と表示されていないこと

  Scenario: グループ参加時のアクション表示
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する

    When "jack@test.com"でログインする
    And "VimGroupグループのトップページ"にアクセスする

    Then "参加する"と表示されていないこと
    And "新着時に通知"と表示されていないこと
    And "記事を書く"と表示されていること
    And "質問を書く"と表示されていること
    And "ファイルをアップ"と表示されていること
    And "退会する"と表示されていること
