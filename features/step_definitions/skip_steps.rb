Then /^flashメッセージに"([^\"]*)"と表示されていること$/ do |message|
  response.body.should =~ /#{Regexp.escape(message.to_json)}/m
end

Then /^flashメッセージに"([^\"]*)"と表示されていないこと$/ do |message|
  response.body.should_not =~ /#{Regexp.escape(message.to_json)}/m
end

When /^"([^\"]*)"リンクを"([^\"]*)"クリックする$/ do |link, method|
  method = method.blank? ? :get : method.downcase.to_sym
  click_link(link, :method => method)
end

Given /^"([^\"]*)"にアクセスする$/ do |page_name|
  Given "I am on #{page_name}"
end

Then /^"([^\"]*)"が選択されていること$/ do |label|
  Then %Q(the "#{label}" checkbox should be checked)
end

When /^再読み込みする$/ do
  visit request.request_uri
end

When /^デバッガで止める$/ do
  require 'ruby-debug'
  debugger
end
