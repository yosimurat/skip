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

describe GroupParticipation do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sg_alice = create_user(:tenant => @sgi, :name => 'Alice')
    @bob = create_user :tenant => @sg, :name => 'ボブ', :admin => false
    @sug = create_tenant(:name => 'SKIPUserGroup')
    @sug_carol = create_user(:tenant => @sug)
  end

  describe GroupParticipation, '#after_save' do
    before do
      Group.record_timestamps = false
      @before_updated_on = Time.now.yesterday
      @vim_group = create_group :tenant => @sg, :name => 'Vim勉強会', :updated_on => @before_updated_on, :created_on => @before_updated_on
    end
    describe '参加待ちの場合' do
      before do
        @vim_group.group_participations.create(:user_id => @bob.id, :waiting => true)
      end
      subject do
        @vim_group.reload.updated_on.to_i
      end
      it '対象ユーザの所属グループの更新日が変わらないこと' do
        should == @before_updated_on.to_i
      end
    end
    describe '参加中の場合' do
      before do
        @vim_group.group_participations.create(:user_id => @bob.id, :waiting => false)
      end
      subject do
        @vim_group.reload.updated_on.to_i
      end
      it '対象ユーザの所属グループの更新日が変わること' do
        should_not == @before_updated_on.to_i
      end
    end
    after do
      Group.record_timestamps = true
    end
  end

  describe GroupParticipation, '#after_destroy' do
    before do
      Group.record_timestamps = false
      @vim_group = create_group :name => 'Vim勉強会' do |g|
        @group_participation = g.group_participations.build(:user => @bob, :owned => true)
      end
      @before_updated_on = Time.now.yesterday
      @vim_group.update_attributes(:updated_on => @before_updated_on, :created_on => @before_updated_on)
    end
    subject do
      @group_participation.destroy
      @vim_group.reload.updated_on.to_i
    end
    it '対象ユーザの所属グループの更新日が更新されること' do
      should_not == @before_updated_on.to_i
    end
    after do
      Group.record_timestamps = true
    end
  end

  describe GroupParticipation, '.joined?' do
    it { pending '後で回帰テストを書く' }
  end

  describe GroupParticipation, '.owned?' do
    it { pending '後で回帰テストを書く' }
  end

  describe GroupParticipation, '#join!' do
    before do
      @unprotected_group = create_group(:tenant => @sg, :name => 'unprotected')
      @protected_group = create_group(:tenant => @sg, :name => 'protected', :protected => true)
    end
    describe 'まだレコードが存在しない場合' do
      before do
        @group_participation = @unprotected_group.group_participations.build(:user => @sg_alice)
      end
      describe '保存に成功する場合' do
        describe '新着通知が既に存在する場合' do
          before do
            @sg_alice.notices.create!(:target => @unprotected_group)
          end
          it 'このグループに対する対象ユーザの新着通知が作成されないこと' do
            lambda do
              @group_participation.join!(@sg_alice)
            end.should_not change(Notice, :count)
          end
        end
        describe '新着通知がまだ存在しない場合' do
          it 'このグループに対する対象ユーザの新着通知が作成されること' do
            lambda do
              @group_participation.join!(@sg_alice)
            end.should change(Notice, :count).by(1)
          end
        end
        it '参加に対するシステムメッセージ作成が行われること' do
          @group_participation.should_receive(:create_join_system_message, @sg_alice)
          @group_participation.join!(@sg_alice)
        end
        describe '承認が必要なグループの場合' do
          describe 'ログインユーザで自分を参加させる場合' do
            before do
              @group_participation = @protected_group.group_participations.build(:user => @bob)
            end
            it '成功すること(対象ユーザは承認待ち状態)' do
              @group_participation.join!(@bob) do |result, object, messages|
                result.should be_true
                messages.should == [ 'Request sent. Please wait for the approval.' ]
              end
            end
          end
          describe 'ログインユーザで他者を参加させる場合' do
            before do
              @group_participation = @protected_group.group_participations.build(:user => @sg_alice)
            end
            it '成功すること(グループへ強制参加)' do
              @group_participation.join!(@bob) do |result, object, messages|
                result.should be_true
                messages.should == [ "Added Alice as a member." ]
              end
            end
          end
        end
        describe '承認が不要なグループの場合' do
          describe 'ログインユーザで自分を参加させる場合' do
            before do
              @group_participation = @unprotected_group.group_participations.build(:user => @bob)
            end
            it '成功すること(グループへ参加)' do
              @group_participation.join!(@bob) do |result, object, messages|
                result.should be_true
                messages.should == [ 'Joined the group successfully.' ]
              end
            end
          end
          describe 'ログインユーザで他者を参加させる場合' do
            before do
              @group_participation = @unprotected_group.group_participations.build(:user => @sg_alice)
            end
            it '成功すること(グループへ強制参加)' do
              @group_participation.join!(@bob) do |result, object, messages|
                result.should be_true
                messages.should == [ "Added Alice as a member." ]
              end
            end
          end
        end
      end
      describe '保存に失敗する場合' do
        before do
          @group_participation.should_receive('save!').and_raise(mock_record_invalid)
        end
        it '失敗すること(Validation Error)' do
          @group_participation.join!(@sg_alice) do |result, object, messages|
            result.should be_false
            messages.should == ["Joined the group failed."]
          end
        end
      end
    end
    describe '既にレコードが存在する場合' do
      before do
        @group_participation = GroupParticipation.create!(:user => @sg_alice, :group => @unprotected_group)
      end
      it '失敗すること(既に参加済み、または承認待ち)' do
        @group_participation.join!(@sg_alice) do |result, object, messages|
          result.should be_false
          messages.should == ["Alice has already joined / applied to join this group."]
        end
      end
    end
  end

  describe GroupParticipation, '#leave' do
    before do
      @group = create_group(:tenant => @sg)
      @group_participation = @group.group_participations.create(:user => @sg_alice)
      @sg_alice.notices.create(:target => @group)
    end
    it '新着が削除されること' do
      lambda do
        @group_participation.leave(@sg_alice)
      end.should change(Notice, :count).by(-1)
    end
    it '参加レコードが削除されること' do
      lambda do
        @group_participation.leave(@sg_alice)
      end.should change(GroupParticipation, :count).by(-1)
    end
    it '退会に対するシステムメッセージ作成が行われること' do
      @group_participation.should_receive(:create_leave_system_message, @sg_alice)
      @group_participation.leave(@sg_alice)
    end
    describe 'ログインユーザで自分を退会させる場合' do
      it '成功すること(グループから退会)' do
        @group_participation.leave(@sg_alice) do |result, object, messages|
          result.should be_true
          messages.should == [ 'Successfully left the group.' ]
        end
      end
    end
    describe 'ログインユーザで他者を退会させる場合' do
      it '成功すること(グループから強制退会)' do
        @group_participation.leave(@bob) do |result, object, messages|
          result.should be_true
          messages.should == [ "Removed Alice from members of the group." ]
        end
      end
    end
  end

  describe GroupParticipation, '#full_accessible?' do
    it { pending '[High]後で回帰テストを書く' }
  end

  # ------------------------------------------------------------
  # privateメソッドのテスト
  # ------------------------------------------------------------
  describe GroupParticipation, '#create_join_system_message' do
    before do
      @group = create_group(:tenant => @sg)
    end
    describe '承認待ちの場合' do
      before do
        @group_participation = @group.group_participations.build(:user => @sg_alice, :waiting => true)
      end
      it 'メッセージが何も作成されないこと' do
        lambda do
          @group_participation.send(:create_join_system_message, @bob)
        end.should_not change(SystemMessage, :count)
      end
    end
    describe '承認待ち以外の場合' do
      before do
        # Tomは管理者
        @group.group_participations.create(:user => create_user(:name => 'Tom', :admin => false), :owned => true)
        # Kateは管理者
        @group.group_participations.create(:user => create_user(:name => 'Kate', :admin => false), :owned => true)
        # Mikeは参加者
        @group.group_participations.create(:user => create_user(:name => 'Mike', :admin => false), :owned => false)
        # 新たな参加者はAlice
        @group_participation = @group.group_participations.build(:user => @sg_alice)
      end
      describe 'ログインユーザで自分を参加させた場合' do
        subject do
          @group_participation.send(:create_join_system_message, @sg_alice)
        end
        it '参加したグループの管理者全員にメッセージが作成されること' do
          should have(2).items
        end
        it 'JOINタイプのメッセージであること' do
          subject.map(&:message_type).all? {|mt| mt == 'JOIN' }.should be_true
        end
      end
      describe 'ログインユーザで他者を参加させた場合' do
        subject do
          @group_participation.send(:create_join_system_message, @bob)
        end
        it '参加させたユーザにメッセージが作成されること' do
          should have(1).items
        end
        it 'FORCED_JOINタイプのメッセージであること' do
          subject.map(&:message_type).all? {|mt| mt == 'FORCED_JOIN' }.should be_true
        end
      end
    end
  end

  describe GroupParticipation, '#create_leave_system_message' do
    before do
      @group = create_group(:tenant => @sg)
      # Tomは管理者
      @group.group_participations.create(:user => create_user(:tenant => @sg, :name => 'Tom', :admin => false), :owned => true)
      # Kateは管理者
      @group.group_participations.create(:user => create_user(:tenant => @sg, :name => 'Kate', :admin => false), :owned => true)
      # Mikeは参加者
      @group.group_participations.create(:user => create_user(:tenant => @sg, :name => 'Mike', :admin => false), :owned => false)
      # 退会するのはAlice
      @group_participation = @group.group_participations.create(:user => @sg_alice)
    end
    describe 'ログインユーザで自分を退会させた場合' do
      subject do
        @group_participation.send(:create_leave_system_message, @sg_alice)
      end
      it '退会したグループの管理者全員にメッセージが作成されること' do
        should have(2).items
      end
      it 'LEAVEタイプのメッセージであること' do
        subject.map(&:message_type).all? {|mt| mt == 'LEAVE' }.should be_true
      end
    end
    describe 'ログインユーザで他者を退会させた場合' do
      subject do
        @group_participation.send(:create_leave_system_message, @bob)
      end
      it '退会させたユーザにメッセージが作成されること' do
        should have(1).items
      end
      it 'FORCED_LEAVEタイプのメッセージであること' do
        subject.map(&:message_type).all? {|mt| mt == 'FORCED_LEAVE' }.should be_true
      end
    end
  end
end
