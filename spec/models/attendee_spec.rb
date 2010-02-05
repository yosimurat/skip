require 'spec_helper'

describe Attendee do
  before(:each) do
    @valid_attributes = {
      
    }
  end

  it "should create a new instance given valid attributes" do
    Attendee.create!(@valid_attributes)
  end
end
