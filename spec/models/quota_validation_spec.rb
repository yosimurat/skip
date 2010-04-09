require File.dirname(__FILE__) + '/../spec_helper'

describe QuotaValidation do
  before do
    @share_file = ShareFile.new
    @muf = mock_uploaed_file
  end
  describe "#validates_size_per_file" do
    subject do
      @share_file.validates_size_per_file(@muf)
      @share_file.errors.full_messages
    end
    describe "ファイルサイズが0の場合" do
      before do
        @muf.stub!(:size).and_return(0)
      end
      it { should == ['Nonexistent or empty files are not accepted for uploading.'] }
    end
    describe "ファイルサイズが最大値を超えている場合" do
      before do
        @muf.stub!(:size).and_return(GlobalInitialSetting['max_share_file_size'].to_i + 1)
      end
      it { should == ["Files larger than #{GlobalInitialSetting['max_share_file_size'].to_i/1.megabyte}MBytes are not permitted."] }
    end
  end

  describe "#validates_size_per_tenant" do
    subject do
      @share_file.validates_size_per_tenant(@muf)
      @share_file.errors.full_messages
    end
    describe "ファイルサイズがオーナーの最大許可容量を超えている場合" do
      before do
        tenant = create_tenant
        tenant.should_receive(:total_file_size).and_return(Admin::Setting.max_total_file_size_per_tenant(tenant).to_i)
        @share_file.tenant = tenant
        @muf.stub!(:size).and_return(1)
      end
      it { should == ['Upload denied due to excess of system wide shared files disk capacity.'] }
    end
  end
end
