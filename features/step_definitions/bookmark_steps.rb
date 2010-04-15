Given /^以下のブックマークを作成する:$/ do |table|
  table.hashes.each do |b_hash|
    t = Tenant.find_by_name(b_hash[:tenant_name]) || create_tenant(:name => b_hash[:tenant_name])
    create_bookmark(:tenant => t, :url => b_hash[:url], :title => b_hash[:title])
  end
end
