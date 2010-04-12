Given /^以下のテナントを作成する$/ do |tenants_table|
  tenants_table.hashes.each do |tenant_hash|
    create_tenant tenant_hash
  end
end
