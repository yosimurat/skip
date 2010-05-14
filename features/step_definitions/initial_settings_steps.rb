Given /^メール機能を有効にする$/ do
  GlobalInitialSetting['mail']['show_mail_function'] = true
end

Given /^質問の告知方法の既定値をメール送信にする機能を"([^\"]*)"にする$/ do |str|
  if str == '有効'
    Admin::Setting.[]=(@current_tenant, "default_send_mail_of_question", true)
  else
    Admin::Setting.[]=(@current_tenant, "default_send_mail_of_question", false)
  end
end
