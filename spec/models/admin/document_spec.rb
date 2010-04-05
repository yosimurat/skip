require 'spec_helper'

describe Admin::Document do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Admin::Document.create!(@valid_attributes)
  end
end
