Feature: マイページ
  ログインしているユーザへの情報をまとめて表示する

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

  Scenario: マイページに表示されている記事のタグをクリックして、そのタグをつけられた記事を探す
    Given 以下のブログを書く:
      |tenant_name  |user   |title                |tag  |contents   |
      |skip         |alice  |Railsの開発について  |雑談 |ほげほげ   |
      |skip         |alice  |別の雑談             |雑談 |ふがふが   |
    When "マイページ"にアクセスする
    And "雑談"リンクをクリックする

    Then "別の雑談"と表示されていること

  Scenario: 質問を表示する
    Given 以下のブログを書く:
      |tenant_name  |user  |title            |aim_type                                              |contents     |
      |skip         |alice |Railsについて質問|質問 (マイページの「みんなからの質問」に表示されます) |わかりません |
      |skip         |alice |Railsについて雑談|記事 (マイページの「新着記事」に表示されます)         |色々話そう   |

    When "マイページ"にアクセスする

    Then I should see "Railsについて質問" within "div#questions_wrapper"
    And I should not see "Railsについて質問" within "div#access_blogs"
    And I should see "Railsについて雑談" within "div#access_blogs"
    And I should not see "Railsについて質問" within "div#recent_blogs"
    And I should see "Railsについて雑談" within "div#recent_blogs"

  Scenario: 新着通知(コメントの行方)の表示
    Given 以下のブログを書く:
      |tenant_name  | user   | title        | aim_type |
      |skip         | alice  | 初めての記事 | 記事 (マイページの「新着記事」に表示されます)           |
    And 以下の記事コメントを書く:
      |entry_title      |contents       |user     |
      |初めての記事     |test1          |alice    |
      |初めての記事     |test2          |jack     |
    
    When "alice@test.com"でログインする

    Then I should see "コメントの行方(1)" within "div.antenna"

#  Scenario: 新着通知(ブクマの行方)の表示
#    Given 以下のブログを書く:
#      |tenant_name  | user   | title        | aim_type |
#      |skip         | alice  | 初めての記事 | 記事 (マイページの「新着記事」に表示されます)           |
#    And "alice@test.com"で"初めての記事"というタイトルのブログをブックマークする
#    And "jack@test.com"で"初めての記事"というタイトルのブログをブックマークする
#
#    When "alice@test.com"でログインする
#
#    Then I should see "ブクマの行方(1)" within "div.antenna"

  Scenario: 新着通知(ユーザ)の表示
    Given "alice@test.com"で"jack@test.com"を新着通知に追加する
    And 以下のブログを書く:
      |tenant_name  | user   | title        | aim_type |
      |skip         | jack  | 初めての記事 | 記事 (マイページの「新着記事」に表示されます)           |

    When "alice@test.com"でログインする

    Then I should see "jack(1)" within "div.antenna"

  Scenario: 新着通知(グループ)の表示
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する
    And 以下のフォーラムを書く:
      |tenant_name  |user  |group       |title            |tag |contents|publication_type|
      |skip         |jack  |VimGroup    |雑談スレ         |雑談|ほげほげ|全体に公開      |

    When "alice@test.com"でログインする

    Then I should see "VimGroup(1)" within "div.antenna"

  Scenario: タブ表示/並べて表示を切り替える
    Given "alice@test.com"でログインする

    When "タブで表示"リンクをクリックする

    Then "新着記事"と表示されていること

    When "並べて表示"リンクをクリックする

    Then "新着記事"と表示されていないこと

  Scenario: システムメッセージ(新着コメント)が表示される
    Given 以下のブログを書く:
      |tenant_name  | user   | title        | aim_type |
      |skip         | alice  | あけおめ     | 記事 (マイページの「新着記事」に表示されます)           |
    And 以下の記事コメントを書く:
      |entry_title      |contents       |user     |
      |あけおめ         |test1          |jack     |

    When "alice@test.com"でログインする

    Then "あなたの記事[あけおめ]に新着コメントがあります！"と表示されていること

    When "あなたの記事[あけおめ]に新着コメントがあります！"リンクをクリックする
    And "マイページ"にアクセスする

    Then "あなたの記事[あけおめ]に新着コメントがあります！"と表示されていないこと

    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する
    And 以下のフォーラムを書く:
      |tenant_name  |user  |group       |title            |tag |contents|publication_type|
      |skip         |alice |VimGroup    |雑談しよう       |雑談|ほげほげ|全体に公開      |
    And 以下の記事コメントを書く:
      |entry_title      |contents       |user     |
      |雑談しよう       |test1          |jack     |

    When "alice@test.com"でログインする

    Then "あなたの記事[雑談しよう]に新着コメントがあります！"と表示されていること

    When "あなたの記事[雑談しよう]に新着コメントがあります！"リンクをクリックする
    And "マイページ"にアクセスする

    Then "あなたの記事[雑談しよう]に新着コメントがあります！"と表示されていないこと

  Scenario: システムメッセージ(トラックバック)が表示される
    Given 以下のブログを書く:
      |tenant_name  | user   | title        | aim_type |
      |skip         | alice  | あけおめ     | 記事 (マイページの「新着記事」に表示されます)           |

    When "jack@test.com"でログインする
    And "あけおめの記事の表示ページ"にアクセスする
    And "[この記事を「話題」にして、新しいブログを書く]"リンクをクリックする
    And "Wikiテキスト"を選択する
    And "board_entry_contents_hiki"に"内容"と入力する
    And "作成"ボタンをクリックする
    And "alice@test.com"でログインする

    Then "あなたの記事を話題にした新着記事[あけおめ]があります！"と表示されていること

    When "あなたの記事を話題にした新着記事[あけおめ]があります！"リンクをクリックする
    And "マイページ"にアクセスする

    Then "あなたの記事を話題にした新着記事[あけおめ]があります！"と表示されていないこと

  Scenario: システムメッセージ(紹介文)が表示される
    Given 以下の紹介文を作成する:
      |from_user        |comment      |to_user        |
      |jack@test.com    |Aliceです。  |alice@test.com |

    When "alice@test.com"でログインする

    Then "あなたの紹介文が追加されました！"と表示されていること

    When "あなたの紹介文が追加されました！"リンクをクリックする
    And "マイページ"にアクセスする

    Then "あなたの紹介文が追加されました！"と表示されていないこと

  Scenario: システムメッセージ(質問の状態変更)が表示される
    Given 以下のブログを書く:
      |tenant_name  | user   | title        | aim_type |
      |skip         | alice  | 初めての質問 | 質問 (マイページの「みんなからの質問」に表示されます)   |
    And "jack@test.com"でログインする
    And "初めての質問"という質問の公開状態を変更する

    When "alice@test.com"でログインする

    Then "あなたの質問 [初めての質問] の公開状態が変更されました。"と表示されていること

    When "あなたの質問 [初めての質問] の公開状態が変更されました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "あなたの質問 [初めての質問] の公開状態が変更されました。"と表示されていないこと

  Scenario: システムメッセージ(管理グループへの参加)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する

    When "alice@test.com"でログインする

    Then "[VimGroup]に新しい参加者がいます!"と表示されていること

    When "[VimGroup]に新しい参加者がいます!"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]に新しい参加者がいます!"と表示されていないこと

  Scenario: システムメッセージ(管理グループからの退会)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する
    And "jack@test.com"が"VimGroup"グループを退会する

    When "alice@test.com"でログインする

    Then "jackさんが[VimGroup]から退会しました。"と表示されていること

    When "jackさんが[VimGroup]から退会しました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "jackさんが[VimGroup]から退会しました。"と表示されていないこと

  Scenario: システムメッセージ(グループへの参加承認)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |true     |
    And "jack@test.com"が"VimGroup"グループに参加する

    #========================================
    # グループ管理者側
    #========================================
    When "alice@test.com"でログインする

    Then "[VimGroup]に承認待ちのユーザがいます!"と表示されていること

    When "[VimGroup]に承認待ちのユーザがいます!"リンクをクリックする

    # 承認画面に遷移
    Then "VimGroupグループの参加者の承認ページ"を表示していること

    When "マイページ"にアクセスする

    # クリックで消えない
    Then "[VimGroup]に承認待ちのユーザがいます!"と表示されていること

    # 承認すると消える
    When "[VimGroup]に承認待ちのユーザがいます!"リンクをクリックする
    And "許可する"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]に承認待ちのユーザがいます!"と表示されていないこと

    #========================================
    # グループ参加申請者側
    #========================================
    When "jack@test.com"でログインする

    Then "[VimGroup]への参加が承認されました。"と表示されていること

    When "[VimGroup]への参加が承認されました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]への参加が承認されました。"と表示されていないこと

  Scenario: システムメッセージ(グループへの参加棄却)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |true     |
    And "jack@test.com"が"VimGroup"グループに参加する

    #========================================
    # グループ管理者側
    #========================================
    When "alice@test.com"でログインする
    And "[VimGroup]に承認待ちのユーザがいます!"リンクをクリックする
    And "棄却する"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]に承認待ちのユーザがいます!"と表示されていないこと

    #========================================
    # グループ参加申請者側
    #========================================
    When "jack@test.com"でログインする

    Then "[VimGroup]への参加が棄却されました。"と表示されていること

    When "[VimGroup]への参加が棄却されました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]への参加が棄却されました。"と表示されていないこと

  Scenario: システムメッセージ(グループへの強制参加)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |true     |
    And "alice@test.com"で"jack"を"VimGroup"グループへ強制参加させる

    When "jack@test.com"でログインする

    Then "[VimGroup]に参加することになりました。"と表示されていること

    When "[VimGroup]に参加することになりました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]に参加することになりました。"と表示されていないこと

  Scenario: システムメッセージ(グループからの強制退会)が表示される
    Given 以下のグループを作成する:
      |name         |owner_email      |waiting  |
      |VimGroup     |alice@test.com   |false    |
    And "jack@test.com"が"VimGroup"グループに参加する
    And "alice@test.com"で"jack@test.com"を"VimGroup"グループから強制退会させる

    When "jack@test.com"でログインする

    Then "[VimGroup]を強制退会しました。"と表示されていること

    When "[VimGroup]を強制退会しました。"リンクをクリックする
    And "マイページ"にアクセスする

    Then "[VimGroup]を強制退会しました。"と表示されていないこと
