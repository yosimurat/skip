require 'spec_helper'

describe Ranking do
  before do
    @sg_tenant = create_tenant(:name => 'sg')
    @sug_tenant = create_tenant(:name => 'sug')
  end

  describe Ranking, '.total' do
    before  do
      @datetime = Time.local(2008, 7, 15)
      with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/foo', :contents_type => 'entry_access') do |me|
        me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 1)
        me.create_ranking(:extracted_on => @datetime, :amount => 2)
        me.create_ranking(:extracted_on => @datetime.tomorrow, :amount => 3)
      end
      with_options(:tenant => @sug_tenant, :url => 'http://user.openskip.org/tenants/2/foo', :contents_type => 'entry_access') do |me|
        me.create_ranking(:extracted_on => @datetime, :amount => 2)
      end
      with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/hoge', :contents_type => 'comment_access') do |me|
        me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 4)
        me.create_ranking(:extracted_on => @datetime, :amount => 5)
        me.create_ranking(:extracted_on => @datetime.tomorrow, :amount => 6)
      end
      create_ranking(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/bar', :contents_type => 'comment_access', :extracted_on => @datetime, :amount => 7)
    end

    it '指定したテナントにおけるurl及び指定したcontents_typeでグルーピングされたランキングが取得できること' do
      Ranking.total(@sg_tenant, :entry_access).should have(1).items
      Ranking.total(@sg_tenant, :comment_access).should have(2).items
    end
    # it 'url及び指定したcontents_type毎にextracted_onが最新のデータが抽出されていること'
  end

  describe Ranking, '.monthly' do
    describe '複数種類のcontents_typeのデータがある場合' do
      before do
        @datetime = Time.local(2008, 7, 15)
        create_ranking(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/foo', :contents_type => 'entry_access', :extracted_on => @datetime, :amount => 2)
        create_ranking(:tenant => @sug_tenant, :url => 'http://user.openskip.org/tenants/2/foo', :contents_type => 'entry_access', :extracted_on => @datetime, :amount => 2)
        create_ranking(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/hoge', :contents_type => 'comment_access', :extracted_on => @datetime, :amount => 5)
      end
      it '指定したテナントにおける指定したcontents_typeのデータのみ抽出されること' do
        Ranking.monthly(@sg_tenant, :entry_access, @datetime.year, @datetime.month).should have(1).items
        Ranking.monthly(@sg_tenant, :comment_access, @datetime.year, @datetime.month).should have(1).items
      end
      it '存在しないcontents_typeのデータは抽出されないこと' do
        Ranking.monthly(@sg_tenant, :hoge, @datetime.year, @datetime.month).should have(0).items
      end
    end

    describe '複数のurlのデータがある場合' do
      before do
        @datetime = Time.local(2008, 7, 15)
        with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/foo', :contents_type => 'comment_access') do |me|
          me.create_ranking(:extracted_on => @datetime, :amount => 5)
          me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 4)
        end
        with_options(:tenant => @sug_tenant, :url => 'http://user.openskip.org/tenants/2/foo', :contents_type => 'comment_access') do |me|
          me.create_ranking(:extracted_on => @datetime, :amount => 5)
          me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 4)
        end
        create_ranking(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/bar', :contents_type => 'comment_access', :extracted_on => @datetime, :amount => 7)
      end
      it '指定したテナントにおいてurlでグルーピングされること' do
        Ranking.monthly(@sg_tenant, :comment_access, @datetime.year, @datetime.month).should have(2).items
      end
    end

    describe '単一のcontents_type及び、単一のurlのデータの場合' do
      describe '前月以前にデータがある場合' do
        before do
          @datetime = Time.local(2008, 7, 15)
          with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/hoge', :contents_type => 'comment_access') do |me|
            me.create_ranking(:extracted_on => @datetime.ago(2.month), :amount => 4)
            me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 4)
            me.create_ranking(:extracted_on => @datetime, :amount => 5)
            me.create_ranking(:extracted_on => @datetime.tomorrow, :amount => 6)
          end
        end
        it '指定月でextracted_onが最大となるレコードのamount - 前月最終日以前でextracted_onが最大となるレコードのamountとなっていること' do
          Ranking.monthly(@sg_tenant, :comment_access, @datetime.year, @datetime.month).first.amount.should == 2 
        end
      end

      describe '前月以前にデータがない場合' do
        before do
          @datetime = Time.local(2008, 7, 15)
          with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/hoge', :contents_type => 'comment_access') do |me|
            me.create_ranking(:extracted_on => @datetime.yesterday, :amount => 4)
            me.create_ranking(:extracted_on => @datetime, :amount => 5)
            me.create_ranking(:extracted_on => @datetime.tomorrow, :amount => 6)
          end
        end
        it '指定月でextracted_onが最大となるレコードのamountとなっていること' do
          Ranking.monthly(@sg_tenant, :comment_access, @datetime.year, @datetime.month).first.amount.should == 6
        end
      end
    end

    describe '単一のcontents_typeで、10種類を超えるurlのデータがある場合' do
      before do
        @datetime = Time.local(2008, 7, 15)
        with_options(:tenant => @sg_tenant, :contents_type => 'comment_access') do |me|
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/1', :extracted_on => @datetime, :amount => 1)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/2', :extracted_on => @datetime, :amount => 2)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/3', :extracted_on => @datetime, :amount => 3)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/4', :extracted_on => @datetime, :amount => 4)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/5', :extracted_on => @datetime, :amount => 5)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/6', :extracted_on => @datetime, :amount => 6)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/7', :extracted_on => @datetime, :amount => 7)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/8', :extracted_on => @datetime, :amount => 8)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/9', :extracted_on => @datetime, :amount => 9)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/10', :extracted_on => @datetime, :amount => 10)
          me.create_ranking(:url => 'http://user.openskip.org/tenant/1/11', :extracted_on => @datetime, :amount => 11)
        end
      end
      it '10件のデータが抽出されること' do
        Ranking.monthly(@sg_tenant, :comment_access, @datetime.year, @datetime.month).should have(10).items
      end
    end

    describe '対象月のデータがなく、対象月以前のデータがある場合' do
      before do
        @target_date = Time.local(2008, 7, 15)
        extracted_on = Time.local(2008, 6, 15)
        with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/1', :contents_type => 'comment_access') do |me|
          me.create_ranking(:extracted_on => extracted_on, :amount => 1)
          me.create_ranking(:extracted_on => extracted_on.tomorrow, :amount => 2)
        end
      end
      it '結果に含まれないこと' do
        Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month).should == []
      end
    end

    describe '対象月のデータがある場合' do
      before do
        @target_month = 4
        @target_date = Time.local(2009, @target_month, 15)
        with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/1', :contents_type => 'comment_access') do |me|
          me.create_ranking(:extracted_on => @target_date, :amount => 100)
          me.create_ranking(:extracted_on => @target_date.tomorrow, :amount => 101)
        end
      end
      describe '対象月の前月以前のデータがある場合' do
        describe '対象月の前月のデータがある場合' do
          before do
            @target_date_ago_one_month = @target_date.ago 1.month
            with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/1', :contents_type => 'comment_access') do |me|
              me.create_ranking(:extracted_on => @target_date_ago_one_month, :amount => 50)
              me.create_ranking(:extracted_on => @target_date_ago_one_month.tomorrow, :amount => 51)
            end
          end
          it 'amountが前月最後のデータとの差分となること' do
            Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month).should have(1).items
            Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month)[0].amount.should == 50
          end
        end
        describe '対象月の前々月のデータがある場合' do
          before do
            @target_date_ago_two_month = @target_date.ago 2.month
            with_options(:tenant => @sg_tenant, :url => 'http://user.openskip.org/tenants/1/1', :contents_type => 'comment_access') do |me|
              me.create_ranking(:extracted_on => @target_date_ago_two_month, :amount => 25)
              me.create_ranking(:extracted_on => @target_date_ago_two_month.tomorrow, :amount => 26)
            end
          end
          it 'amountが前々月最後のデータとの差分となること' do
            Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month).should have(1).items
            Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month)[0].amount.should == 75
          end
        end
      end
      describe '対象の前月以前のデータがない場合' do
        it 'amountが対象月最後のデータとの差分となること' do
          Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month).should have(1).items
          Ranking.monthly(@sg_tenant, :comment_access, @target_date.year, @target_date.month)[0].amount.should == 101
        end
      end
    end
  end

  describe Ranking, '.extracted_dates' do
    subject {
      Ranking.extracted_dates(@sg_tenant)
    }
    describe 'extracted_onが同月のレコードが2件の場合' do
      before do
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 11, 1))
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 11, 2))
      end
      it { should == ['2008-11'] }
    end
    describe 'extracted_onが異なる月のレコードが2件の場合' do
      before do
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 11, 1))
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 12, 1))
      end
      it { should == ['2008-12', '2008-11'] }
    end
    describe 'extracted_onが同月のレコードが2件、異なる月のレコードが1件の場合' do
      before do
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 11, 1))
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 11, 2))
        create_ranking(:tenant => @sg_tenant, :extracted_on => Time.local(2008, 12, 1))
      end
      it { should == ['2008-12', '2008-11'] }
    end
  end
end
