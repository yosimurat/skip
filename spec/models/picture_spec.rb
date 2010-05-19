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

describe Picture do
  before do
    @sg = create_tenant(:name => 'SonicGarden')
    @sg_alice = create_user(:tenant => @sg, :name => 'Alice')
    @sg_jack = create_user(:tenant => @sg, :name => 'Jack')
    @sug = create_tenant(:name => 'SKIPUserGroup')
    @sug_carol = create_user(:tenant => @sug)
  end

  describe Picture, 'valid?' do
    include ActionController::TestProcess
    describe 'プロフィール画像の変更権限がない場合は保存出来ない' do
      before do
        Admin::Setting.set_enable_change_picture(@sg, 'false')
        @picture = Picture.new(:content_type => 'image/png', :user => @sg_alice)
      end
      it 'プロフィール画像が変更出来ないエラーが設定されること' do
        @picture.valid?
        @picture.errors.full_messages.should == ['Picture could not be changed.']
      end
      it '保存に失敗すること' do
        @picture.valid?.should be_false
      end
      after do
        Admin::Setting.set_enable_change_picture(@sg, true)
      end
    end

    describe "content_typeが空の場合" do
      before do
        @picture = Picture.new(:file => fixture_file_upload("data/profile.png", nil, true), :user => @sg_alice)
      end
      it "エラーが起らないこと" do
        lambda do
          @picture.save
        end.should_not raise_error
      end
    end
  end

  describe Picture, 'activate!' do
    it { pending '後で回帰テストを書く' }
  end
end
