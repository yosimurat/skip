require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'spec', 'skip_helper'))
module Cucumber
  module Rails
    module Skip
      module ModelHelpers
        include Spec::Rails::Skip::ModelHelpers
      end
      module FormSubmissionHelpers
        def fill_in_login_form(user_name)
          user = User.find_by_name(user_name)
          Given %!"ログインページ"にアクセスする!
          Given %!"#{"ログインID"}"に"#{user.email}"と入力する!
          Given %!"#{"パスワード"}"に"#{"Password1"}"と入力する!
          Given %!"#{"ログイン"}"ボタンをクリックする!
          user
        end
      end
    end
  end
end

World(Cucumber::Rails::Skip::ModelHelpers, Cucumber::Rails::Skip::FormSubmissionHelpers)
