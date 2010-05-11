Given /^以下の記事ポイントを作成する:$/ do |table|
  table.hashes.each do |point_hash|
    entry = BoardEntry.find_by_title!(point_hash[:entry_title])
    tenant = entry.tenant
    user = tenant.users.find_by_name!(point_hash[:user])
    Given %!"#{user.email}"でログインする!
    point_hash[:count].to_i.times do
      visit(polymorphic_url([tenant, entry.owner, entry, :board_entry_point], :action => :pointup, :format => :js), :put)
    end
  end
end
