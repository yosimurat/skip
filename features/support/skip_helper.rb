require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'spec', 'skip_helper'))
module Cucumber
  module Rails
    module SkipHelpers
      include Spec::Rails::Skip::ModelHelpers
    end
  end
end

World(Cucumber::Rails::SkipHelpers)
