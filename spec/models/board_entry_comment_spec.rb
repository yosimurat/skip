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

describe BoardEntryComment do
  describe BoardEntryComment, 'valid?' do
    describe "正しい値が設定されていない場合" do
      subject {
        BoardEntryComment.new
      }
      it { should_not be_valid }
      it { should have(1).errors_on(:board_entry_id) }
      it { should have(1).errors_on(:contents) }
      it { should have(1).errors_on(:user_id) }
    end

    describe BoardEntryComment, "正しい値が設定されている場合" do
      subject {
        BoardEntryComment.new({ :board_entry_id => 1, :user_id => 1, :contents => "hoge" })
      }

      it { should be_valid }
    end
  end

  describe BoardEntryComment, '#after_save' do
    it { pending '後で回帰テストを書く' }
  end

  describe BoardEntryComment, '#full_accessible?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe BoardEntryComment, '#writer?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  describe BoardEntryComment, '#reflect_user_reading' do
    before do
      @tenant = create_tenant
      @alice = create_user({:tenant => @tenant, :name => 'アリス', :admin => true})
      @jack = create_user({:tenant => @tenant, :name => 'ジャック', :admin => true})
      entry = create_board_entry(:tenant => @tenant, :owner => @alice, :publication_type => 'public', :user => @alice)
      @comment = create_board_entry_comment(:board_entry => entry, :user => @alice)
    end
    describe 'コメントの作成/更新者が指定ユーザと同一の場合' do
      it '未読が作成されないこと' do
        lambda do
          @comment.reflect_user_reading @alice
        end.should_not change(UserReading, :count)
      end
    end
    describe 'コメントの作成/更新者が指定ユーザと異なる場合' do
      describe '指定ユーザにコメントを作成/更新した記事の閲覧権限がある場合' do
        describe 'コメントの更新時刻以前に指定ユーザの既読がある場合' do
          before do
            @user_reading = create_user_reading(:user => @jack, :board_entry => @comment.board_entry, :read => true, :checked_on => @comment.updated_on.ago(1.minute))
          end
          subject {
            @comment.reflect_user_reading @jack
            @user_reading.reload
          }
          it 'その既読が未読に更新されること' do
            subject.read.should be_false
          end
          it 'その既読のチェック日時がクリアされること' do
            subject.checked_on.should be_nil
          end
        end
        describe 'コメントの更新時刻以前に指定ユーザの既読がない場合' do
          subject {
            @comment.reflect_user_reading @jack
            UserReading.count
          }
          it { should == 1 }
        end
      end
      describe '指定ユーザにコメントを作成/更新した記事の閲覧権限がない場合' do
        before do
          @comment.board_entry.should_receive(:accessible?).with(@jack).and_return(false)
        end
        it '未読が作成されないこと' do
          lambda do
            @comment.reflect_user_reading @jack
          end.should_not change(UserReading, :count)
        end
      end
    end
  end
end
