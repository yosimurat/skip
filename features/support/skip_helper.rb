require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'spec', 'skip_helper'))
module Cucumber
  module Rails
    module Skip
      module ModelHelpers
        include Spec::Rails::Skip::ModelHelpers
      end
      module FormSubmissionHelpers
        def fill_in_login_form(email)
          user = User.find_by_email(email)
          Given %!"ログインページ"にアクセスする!
          Given %!"#{"ログインID"}"に"#{user.email}"と入力する!
          Given %!"#{"パスワード"}"に"#{"Password1"}"と入力する!
          Given %!"#{"ログイン"}"ボタンをクリックする!
          @current_user = user
          @current_tenant = user.tenant
        end
      end
    end
  end
end

World(Cucumber::Rails::Skip::ModelHelpers, Cucumber::Rails::Skip::FormSubmissionHelpers)
