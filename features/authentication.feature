# SKIP(Social Knowledge & Innovation Platform)
# Copyright (C) 2008-2010 TIS Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

Feature: パスワードでログインする
  あるユーザとして、SKIPにログインしたい

  Background:
    Given 言語は"ja-JP"
    And 以下のテナントを作成する
      |name   |
      |skip   |
      |sg     |
    And 以下のユーザを作成する
      |name    |email           |password   |tenant_name  |
      |alice   |alice@test.com  |Password1  |skip         |
      |jack    |jack@test.com   |Password1  |sg           |

  Scenario: ログイン画面を表示する
    When "ログインページ"にアクセスする
    Then "ログイン"と表示されていること

  Scenario: skipテナントへのログインに成功する
    When "ログインページ"にアクセスする
    And  "ログインID"に"alice@test.com"と入力する
    And  "パスワード"に"Password1"と入力する
    And  "ログイン"ボタンをクリックする

    Then "skipテナントのマイページ"を表示していること
    And "マイページ"と表示されていること

  Scenario: パスワード間違いによりログインに失敗する
    When "ログインページ"にアクセスする
    And "ログインID"に"alice@test.com"と入力する
    And "パスワード"に"hogehoge"と入力する
    And "ログイン"ボタンをクリックする

    Then flashメッセージに"ログインに失敗しました。"と表示されていること

  Scenario: アカウントがロックされていることによりログインに失敗する
    Given "alice@test.com"をロックする

    When "ログインページ"にアクセスする
    And "ログインID"に"alice@test.com"と入力する
    And "パスワード"に"Password1"と入力する
    And "ログイン"ボタンをクリックする

    Then flashメッセージに"ログインIDがロックされています。パスワード再設定を行って下さい。"と表示されていること
