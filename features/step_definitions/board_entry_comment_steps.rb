Given /^以下の記事コメントを書く:$/ do |table|
  table.hashes.each do |entry_hash|
    entry = BoardEntry.find_by_title!(entry_hash[:entry_title])
    tenant = entry.tenant
    user = tenant.users.find_by_name!(entry_hash[:user])
    Given %!"#{user.email}"でログインする!
    visit(polymorphic_url([tenant, entry.owner, entry, :board_entry_comments], :board_entry_comment => {:contents => entry_hash[:contents]}), :post)
  end
end
