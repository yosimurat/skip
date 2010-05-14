Feature: 共有ファイルの管理
  ユーザは、共有ファイルの作成/表示/更新/削除をすることができる

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
    And 以下のグループを作成する:
      |name     |owner_email      |default_publication_type  |
      |SUG      |alice@test.com   |全体に公開               |
      |VimGroup |alice@test.com   |参加者のみ               |

  Scenario: ユーザが所有する共有ファイルの作成に成功する
    When "alice@test.com"でログインする
    And "ファイルをアップ"リンクをクリックする

    Then "全体に公開"が選択されていること

  Scenario: グループが所有する共有ファイルの作成に成功する
    When "alice@test.com"でログインする
    And "SUGグループのトップページ"にアクセスする
    And "ファイルをアップ"リンクをクリックする

    Then "全体に公開"が選択されていること

    When "VimGroupグループのトップページ"にアクセスする
    And show me the page
    And "ファイルをアップ"リンクをクリックする
    And show me the page

    Then "参加者のみ"が選択されていること

