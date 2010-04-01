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

require File.dirname(__FILE__) + '/../../spec_helper'

describe Search::HyperEstraier, "#search" do
  before do
    @node = mock('node')
    @node.stub!(:search)
    @tenant = create_tenant
    @tenant.stub!(:node).and_return(@node)
    @user = create_user(:tenant => @tenant)
  end
  describe "検索クエリが入力されていない場合" do
    subject {
      Search::HyperEstraier.search({:query => ''}, @user)
    }
    it "エラーが投げられること" do
      subject.error.should == "Please input search query."
    end
  end
  describe "検索クエリが入力されている場合" do
    subject {
      Search::HyperEstraier.search({:query => 'query'}, @user)
    }
    it "per_pageを設定すること" do
      subject.per_page.should == 10
    end
    it "offsetを設定すること" do
      subject.offset.should == 0
    end
    describe "HyperEstraierで検索結果がみつかった場合" do
      subject {
        Search::HyperEstraier.search({:query => 'query'}, @user)
      }
      it '結果のheaderが設定されること' do
        subject.result[:header].should_not be_nil 
      end
      it '結果のelementesが設定されること' do
        subject.result[:elements].should_not be_nil
      end
    end
    describe "ノードにアクセス出来ない場合" do
      before do
        @node.should_receive(:search).and_return(nil)
      end
      subject {
        Search::HyperEstraier.search({:query => 'query'}, @user)
      }
      it "エラーが投げられること" do
        subject.error.should == "Access denied by search node. Please contact system owner."
      end
    end
  end
end

describe Search::HyperEstraier, ".get_condition" do
  it "queryが設定されている場合 queryが設定されること" do
    cond = Search::HyperEstraier.get_condition("query")
    cond.phrase.should == "query"
  end
  it "optionsがSIMPLEに設定されていること" do
    cond = Search::HyperEstraier.get_condition("query")
    cond.options.should == Search::HyperEstraier::Condition::SIMPLE
  end
  describe "target_aidが設定されている場合" do
    before do
      GlobalInitialSetting['search_apps'] = { "app" => {} }
    end
    it "正しいattrが設定されていること" do
      cond = Search::HyperEstraier.get_condition("query", "app")
      cond.attrs.should == ["@aid STREQ app"]
    end
    describe "target_contentsが設定されている場合" do
      it "正しいattrが設定されていること" do
        cond = Search::HyperEstraier.get_condition("query", "app", "contents")
        cond.attrs.should == ["@aid STREQ app", "@object_type STREQ contents"]
      end
    end
  end
end
