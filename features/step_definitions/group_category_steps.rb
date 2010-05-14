Given /^以下のグループカテゴリを作成する:$/ do |table|
  table.hashes.each do |h|
    tenant = Tenant.find_by_name(h[:tenant_name]) || create_tenant
    create_group_category({
      :tenant => tenant,
      :code => (h[:code] || 'code'),
      :name => (h[:name] || 'グループカテゴリ名'),
      :description => (h[:description] || '説明')
    })
  end
end
