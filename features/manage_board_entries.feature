Feature: 記事の管理
  ユーザは、記事の作成/表示/更新/削除や、記事にコメントをすることができる

  Background:
    Given   言語は"ja-JP"

  Scenario: ユーザとしてログインIDで直接指定された記事を表示できる
    Given   "a_group_owned_user"で"uid:100001"を直接指定したブログを書く
    When    "a_user"で"1"つめのブログにアクセスする
    Then    flashメッセージに"閲覧権限がありません。"と表示されていること

  Scenario: ユーザとしてユーザ名で直接指定された記事を表示できる
    Given   "a_group_owned_user"で"uid:a_user"を直接指定したブログを書く
    When    "a_user"で"1"つめのブログにアクセスする
    Then    flashメッセージに"閲覧権限がありません。"と表示されていないこと

  Scenario: ユーザとして参加しているグループの全体公開の記事を表示できる
    Given   以下の掲示板を書く:
        |user               |group      |title      |tag    |contents   |publication_type   |
        |a_group_owned_user |vim_group  |Vimとは    |雑談   |foobar     |全体に公開         |

    When    "a_group_owned_user"で"vim_group"グループのサマリページを開く
    And     "掲示板"リンクをクリックする
    And     "Vimとは"リンクをクリックする

    Then    "Vimとは"と表示されていること
    And     "この記事を「話題」にして、掲示板に新しい記事を投稿する"と表示されていること
    And     "この記事を「話題」にして、新しいブログを書く"と表示されていること

  Scenario: ユーザとして参加していないグループの全体公開の記事を表示できる
    Given   以下の掲示板を書く:
        |user               |group      |title      |tag    |contents   |publication_type   |
        |a_group_owned_user |vim_group  |Vimとは    |雑談   |foobar     |全体に公開         |

    When    "a_user"で"vim_group"グループのサマリページを開く
    And     "掲示板"リンクをクリックする
    And     "Vimとは"リンクをクリックする

    Then    "Vimとは"と表示されていること
    And     "この記事を「話題」にして、掲示板に新しい記事を投稿する"と表示されていないこと
    And     "この記事を「話題」にして、新しいブログを書く"と表示されてること

  Scenario: ユーザとしてグループの掲示板の作成画面の公開範囲の初期値が適切に選択されている
    Given   "a_user"で"vim_group"というグループを作成する

    When    "新規投稿"リンクをクリックする

    Then    "参加者のみ"が選択されていること

    When    "a_user"で"vim_group"グループのサマリページを開く
    And     "管理"リンクをクリックする
    And     "全体に公開"を選択する
    And     "更新"ボタンをクリックする
    And     "新規投稿"リンクをクリックする

    Then    "全体に公開"が選択されていること

  Scenario: ユーザとしてグループの掲示板の作成し、編集する
    Given   "a_user"で"vim_group"というグループを作成する
    And     "新規投稿"リンクをクリックする

    Then    "テストグループの掲示板を書く"と表示されていること

    When    "作成"ボタンをクリックする

    Then    "テストグループの掲示板を書く"と表示されていること
    And     "タイトルを入力してください。"と表示されていること
    And     "内容を入力してください。"と表示されていること

    When    "タイトル"に"タイトル"と入力する
    And     "Wikiテキスト"を選択する
    And     "内容"に"内容"と入力する
    And     "作成"ボタンをクリックする

    Then    flashメッセージに"正しく作成されました。"と表示されていること

    When    "編集"リンクをクリックする

    Then    "テストグループの掲示板を編集"と表示されていること

    When     "タイトル"に""と入力する
    And     "更新"ボタンをクリックする

    Then    "テストグループの掲示板を編集"と表示されていること
    And     "タイトルを入力してください。"と表示されていること

    And     "board_entry[title]"に"更新記事のタイトル"と入力する
    And     "更新"ボタンをクリックする

    Then    flashメッセージに"記事の更新に成功しました。"と表示されていること
    And    "更新記事のタイトル"と表示されていること

  Scenario: ブログの作成に成功する
    Given   "a_user"でログインする

    When    "ブログを書く"リンクをクリックする

    Then    "a_userのブログを書く"と表示されていること

    When    "作成"ボタンをクリックする

    Then    "a_userのブログを書く"と表示されていること
    And     "タイトルを入力してください。"と表示されていること
    And     "内容を入力してください。"と表示されていること

    When    "タイトル"に"タイトル"と入力する
    And     "Wikiテキスト"を選択する
    And     "内容"に"内容"と入力する
    And     "作成"ボタンをクリックする

    Then    flashメッセージに"正しく作成されました。"と表示されていること

  Scenario: ブログの記事を更新する
    Given   "a_user"でブログを書く

    When    "a_user"で"1"つめのブログにアクセスする
    And     "編集"リンクをクリックする

    Then    "a_userのブログを編集"と表示されていること

    When     "タイトル"に""と入力する
    And     "更新"ボタンをクリックする

    Then    "a_userのブログを編集"と表示されていること
    And     "タイトルを入力してください。"と表示されていること

    And     "board_entry[title]"に"更新記事のタイトル"と入力する
    And     "更新"ボタンをクリックする

    Then    flashメッセージに"記事の更新に成功しました。"と表示されていること
    And    "更新記事のタイトル"と表示されていること

  #============================================================
  # コメントの管理
  #============================================================
  Scenario: ユーザとして空のコメントが登録できない
    Given   "a_user"でブログを書く
    When    "コメントを書く"に""と入力する
    And     "書き込み"ボタンをクリックする
    Then    "不正なパラメタです。"と表示されること

  Scenario: ユーザとして妥当なコメントが登録できる
    Given   "a_user"でブログを書く
    When    "コメントを書く"に"コメント"と入力する
    And     "書き込み"ボタンをクリックする
    Then    "新着"と表示されること
    And     "コメント"と表示されること

  Scenario: 他のユーザが新しく登録したコメントは未読コメントとして表示される
    Given   "a_user"でブログを書く
    When    "a_group_owned_user"で"1"つめのブログにアクセスする
    And     "コメントを書く"に"新規に入力したコメント"と入力する
    And     "書き込み"ボタンをクリックする
    And     "a_user"で"1"つめのブログにアクセスする
    Then    "[未読]"と表示されること
    And     "新規に入力したコメント"と表示されること
    When    再読み込みする
    Then    "[未読]"と表示されていないこと

  Scenario: ユーザとしてGoodJobポイントを追加できる
    Given   "a_user"でブログを書く
    And     "a_group_owned_user"で"1"つめのブログにアクセスする
    When    "0 GoodJob"ボタンをクリックする
    Then    "1 GoodJob"と表示されること
