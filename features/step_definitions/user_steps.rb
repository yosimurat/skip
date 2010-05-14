Given /^以下のユーザを作成する$/ do |users_table|
  users_table.hashes.each do |user_hash|
    t = Tenant.find_by_name(user_hash[:tenant_name]) || create_tenant(:name => user_hash[:tenant_name])
    create_user(:tenant => t, :name => user_hash[:name], :email => user_hash[:email], :password => user_hash[:password], :admin => user_hash[:admin], :status => user_hash[:status])
  end
end

Given /^"([^\"]*)"をロックする$/ do |user_key|
  u = User.find_by_email(user_key)
  u.locked = true
  u.save!
end

Given /^プロフィール項目が登録されていない$/ do
  UserProfileMaster.destroy_all
end

Given /^"([^\"]*)"が退職する$/ do |email|
  u = User.find_by_email(email)
  u.status = "RETIRED"
  u.save
end

