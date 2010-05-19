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

describe Group do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sg_alice = create_user(:tenant => @sg, :name => 'Alice')
    @sg_jack = create_user(:tenant => @sg, :name => 'Jack')
    @sug = create_tenant(:name => 'SKIPUserGroup')
    @sug_carol = create_user(:tenant => @sug)
  end

  describe Group, ".has_waiting_for_approval" do
    describe "あるユーザの管理しているグループに承認待ちのユーザがいる場合" do
      before do
        @group = create_group(:tenant => @sg, :name => 'SKIPグループ') do |g|
          g.group_participations.build(:user_id => @sg_alice.id, :owned => true, :waiting => true)
        end
      end
      it '指定したユーザに対する承認待ちのグループが取得できること' do
        Group.has_waiting_for_approval(@sg_alice).first.should == @group
      end
      describe '承認待ちになっているグループが削除された場合' do
        before do
          @group.destroy
        end
        it '対象のグループが取得できないこと' do
          Group.has_waiting_for_approval(@sg_alice).should be_empty
        end
      end
    end
  end

  describe Group, 'after_save' do
    describe '承認が必要なグループが承認不要に変更される場合' do
      before do
        @group = create_group(:tenant => @sg, :protected => true)
        @participation = @group.group_participations.create!(:user => @sg_alice, :waiting => true)
        @group.update_attributes!(:protected => false)
      end
      context '承認待ちのユーザ' do
        subject do
          @group.reload
        end
        it "承認待ちのユーザは全て参加済みになっていること" do
          @group.users.should be_include(@sg_alice)
        end
      end
    end
  end

  describe Group, '.valid?' do
    subject {
      @group.valid?
      @group
    }
    describe 'group_category_id' do
      describe 'group_category_idに対するGroupCategoryが存在する場合' do
        before do
          gc = create_group_category(:tenant => @sg)
          @group = Group.new(:tenant => @sg, :group_category => gc)
        end
        it { should have(0).errors_on(:group_category_id) }
      end
      describe 'group_category_idに対するGroupCategoryが存在しない場合' do
        before do
          @group = Group.new(:tenant => @sg, :group_category_id => 999)
        end
        it { should have(1).errors_on(:group_category_id) }
      end
    end
    describe 'default_publication_type' do
      describe 'publicを指定' do
        before do
          @group = Group.new(:tenant => @sg, :default_publication_type => 'public')
        end
        it { should have(0).errors_on(:default_publication_type) }
      end
      describe 'privateを指定' do
        before do
          @group = Group.new(:tenant => @sg, :default_publication_type => 'private')
        end
        it { should have(0).errors_on(:default_publication_type) }
      end
      describe 'public, private以外を指定' do
        before do
          @group = Group.new(:tenant => @sg, :default_publication_type => 'foo')
        end
        it { should have(1).errors_on(:default_publication_type) }
      end
    end
  end

  describe Group, "#owners あるグループに管理者がいる場合" do
    before do
      @group = create_group(:tenant => @sg, :name => 'SKIPグループ') do |g|
        g.group_participations.build(:user_id => @sg_alice.id, :owned => true)
        g.group_participations.build(:user_id => @sg_jack.id)
      end
    end

    it "管理者ユーザが返る" do
      @group.owners.should == [@sg_alice]
    end
  end
end
