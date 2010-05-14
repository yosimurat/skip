Given /^"(.*)"でログインする$/ do |email|
  if @current_user
    if @current_user.email != email
      Given "ログアウトする"
      fill_in_login_form(email)
    else
      Given %!"#{@current_user.tenant.name}テナントのマイページ"にアクセスする!
    end
  else
    fill_in_login_form(email)
  end
end

Given /^ログアウトする$/ do
  visit logout_platform_path
end
