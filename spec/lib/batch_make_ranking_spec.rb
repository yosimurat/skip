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

require File.dirname(__FILE__) + '/../spec_helper'

describe BatchMakeRanking do
  before do
    @exec_date = Date.today
    @maker = BatchMakeRanking.new
  end
  # アクセス数
  describe BatchMakeRanking, '#create_access_ranking' do
    describe '更新日付が実行日のBoardEntryPointが存在する場合' do
      before do
        setup_test_data
      end
      subject do
        @maker.send(:create_access_ranking, @exec_date)
      end
      describe 'BoardEntryPointのアクセス数(access_count)が1以上のレコードが存在する場合' do
        before do
          @board_entry_point.update_attributes!(:access_count => 1)
        end
        describe '記事が全公開の場合' do
          before do
            @board_entry.update_attribute('publication_type', 'public')
          end
          it 'ランキングが生成されること' do
            execute_create_access_ranking.should change(Ranking, :count).by(1)
          end
        end
        describe '記事が全公開ではない場合' do
          before do
            @board_entry.update_attribute('publication_type', 'private')
          end
          it 'ランキングが生成されないこと' do
            execute_create_access_ranking.should change(Ranking, :count).by(0)
          end
        end
      end
      describe 'BoardEntryPointのアクセス数(access_count)が1以上のレコードが存在しない場合' do
        before do
          @board_entry_point.update_attributes!(:access_count => 0)
        end
        it 'ランキングが生成されないこと' do
          execute_create_access_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    def execute_create_access_ranking
      lambda { @maker.send(:create_access_ranking, @exec_date) }
    end
  end

  # goodjob数
  describe BatchMakeRanking, '#create_point_ranking' do
    describe '更新日付が実行日のBoardEntryPointが存在する場合' do
      before do
        setup_test_data
      end
      describe 'BoardEntryPointのpointが1以上のレコードが存在する場合' do
        before do
          @board_entry_point.update_attributes!(:point => 1)
        end
        describe '記事が全公開の場合' do
          before do
            @board_entry.update_attribute('publication_type', 'public')
          end
          it 'ランキングが生成されること' do
            execute_create_point_ranking.should change(Ranking, :count).by(1)
          end
        end
        describe '記事が全公開ではない場合' do
          before do
            @board_entry.update_attribute('publication_type', 'private')
          end
          it 'ランキングが生成されないこと' do
            execute_create_point_ranking.should change(Ranking, :count).by(0)
          end
        end
      end
      describe 'BoardEntryPointのpointが1以上のレコードが存在しない場合' do
        before do
          @board_entry_point.update_attributes!(:point => 0)
        end
        it 'ランキングが生成されないこと' do
          execute_create_point_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    def execute_create_point_ranking
      lambda { @maker.send(:create_point_ranking, @exec_date) }
    end
  end

  # コメント数
  describe BatchMakeRanking, '#create_comment_ranking' do
    describe '更新日付が実行日のBoardEntryが存在する場合' do
      before do
        setup_test_data
      end
      describe '実行日付にコメントが作成された場合' do
        before do
          create_board_entry_comment(:user_id => @user.id, :board_entry => @board_entry)
        end
        describe '記事が全公開の場合' do
          before do
            @board_entry.update_attribute('publication_type', 'public')
          end
          it 'ランキングが生成されること' do
            execute_create_comment_ranking.should change(Ranking, :count).by(1)
          end
        end
        describe '記事が全公開ではない場合' do
          before do
            @board_entry = @board_entry.reload
            @board_entry.update_attribute('publication_type', 'private')
          end
          it 'ランキングが生成されないこと' do
            execute_create_comment_ranking.should change(Ranking, :count).by(0)
          end
        end
      end
      describe '実行日付にコメントが2つ作成された場合' do
        before do
          create_board_entry_comment(:user_id => @user.id, :board_entry => @board_entry)
          create_board_entry_comment(:user_id => @user.id, :board_entry => @board_entry)
        end
        describe '記事が全公開の場合' do
          before do
            @board_entry.update_attribute('publication_type', 'public')
          end
          it 'ランキングが1つ生成されること' do
            execute_create_comment_ranking.should change(Ranking, :count).by(1)
          end
        end
        describe '記事が全公開ではない場合' do
          before do
            @board_entry = @board_entry.reload
            @board_entry.update_attribute('publication_type', 'private')
          end
          it 'ランキングが生成されないこと' do
            execute_create_comment_ranking.should change(Ranking, :count).by(0)
          end
        end
      end
      describe '実行日付以前にコメントが作成されて、実行日付に記事が更新された場合' do
        before do
          create_board_entry_comment(:user_id => @user.id, :board_entry => @board_entry, :created_on => @exec_date.yesterday)
        end
        it 'ランキングが生成されないこと' do
          execute_create_comment_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    def execute_create_comment_ranking
      lambda { @maker.send(:create_comment_ranking, @exec_date) }
    end
  end

  # 投稿数
  describe BatchMakeRanking, '#create_post_ranking' do
    before do
      BoardEntry.delete_all
    end
    describe '更新日付が実行日のBoardEntryが存在する場合' do
      before do
        setup_test_data
      end
      describe 'BoardEntryの記事種別(entry_type)が(DIARY)なレコードが存在する場合' do
        before do
          @board_entry.update_attributes!(:entry_type => BoardEntry::DIARY)
        end
        it 'ランキングが生成されること' do
          execute_create_post_ranking.should change(Ranking, :count).by(1)
        end
      end
      describe 'BoardEntryの記事種別(entry_type)が(DIARY)なレコードが存在しない場合' do
        before do
          @board_entry.update_attributes!(:entry_type => 'BBS')
        end
        it 'ランキングが生成されないこと' do
          execute_create_post_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    def execute_create_post_ranking
      lambda { @maker.send(:create_post_ranking, @exec_date) }
    end
  end

  # 訪問者数
  describe BatchMakeRanking, '#create_visited_ranking' do
    before do
      UserAccess.delete_all
    end
    describe '更新日付が実行日のUserAccessが存在する場合' do
      before do
        setup_test_data
        @user_access = create_user_access(:user => @user)
      end
      describe 'UserAccessのアクセス数(access_count)が1以上のレコードが存在する場合' do
        before do
          @user_access.update_attributes!(:access_count => 1)
        end
        it 'ランキングが生成されること' do
          execute_create_visited_ranking.should change(Ranking, :count).by(1)
        end
      end
      describe 'UserAccessのアクセス数(access_count)が1以上のレコードが存在しない場合' do
        before do
          @user_access.update_attributes!(:access_count => 0)
        end
        it 'ランキングが生成されないこと' do
          execute_create_visited_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    describe '更新日付が実行日前日のUserAccessが存在する場合' do
      before do
        setup_test_data
        UserAccess.record_timestamps = false
        @user_access_ago_1_day = create_user_access(:user => @user, :updated_on => @exec_date.ago(1.day))
      end
      describe 'UserAccessのアクセス数(access_count)が1以上のレコードが存在する場合' do
        before do
          @user_access_ago_1_day.update_attributes!(:access_count => 1)
        end
        it 'ランキングが生成されないこと' do
          execute_create_visited_ranking.should change(Ranking, :count).by(0)
        end
      end
      after do
        UserAccess.record_timestamps = true
      end
    end
    def execute_create_visited_ranking
      lambda { @maker.send(:create_visited_ranking, @exec_date) }
    end
  end

  # コメンテータ
  describe BatchMakeRanking, '#create_commentator_ranking' do
    before do
      BoardEntryComment.delete_all
    end
    describe '更新日付が実行日以前のBoardEntryCommentが存在する場合' do
      before do
        setup_test_data
        @board_entry_comment = create_board_entry_comment(:user_id => @user.id, :board_entry => @board_entry)
      end
      describe '実行日のコメントが存在する場合' do
        before do
          @board_entry_comment.update_attributes!(:updated_on => @exec_date)
        end
        it 'ランキングが生成されること' do
          execute_create_commentator_ranking.should change(Ranking, :count).by(1)
        end
      end
      describe '実行日のコメントが存在しない場合' do
        before do
          BoardEntryComment.record_timestamps = false
          @board_entry_comment.update_attributes!(:updated_on => @exec_date.tomorrow)
          BoardEntryComment.record_timestamps = true
        end
        it 'ランキングが生成されないこと' do
          execute_create_commentator_ranking.should change(Ranking, :count).by(0)
        end
      end
    end
    def execute_create_commentator_ranking
      lambda { @maker.send(:create_commentator_ranking, @exec_date) }
    end
  end

  def setup_test_data
    @sg_tenant = create_tenant(:name => 'sg')
    @user = create_user(:tenant => @sg_tenant, :name => 'とあるゆーざ', :status => 'ACTIVE')
    @board_entry = create_board_entry(:tenant => @sg_tenant, :user_id => @user.id)
    @board_entry_point = create_board_entry_point(:board_entry_id => @board_entry.id, :updated_on => @exec_date)
  end
end
