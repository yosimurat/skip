require 'spec_helper'

describe Logo do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Logo.create!(@valid_attributes)
  end
end
