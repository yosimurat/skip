Given /^以下のブックマークコメントを作成する:$/ do |table|
  table.hashes.each do |bc_hash|
    u = User.find_by_name!(bc_hash[:user_name])
    b = Bookmark.find_by_url(bc_hash[:bookmark_url]) || create_bookmark(:tenant => u.tenant, :url => bc_hash[:bookmark_url], :title => bc_hash[:url])
    b.bookmark_comments.create!(:comment => bc_hash[:comment], :public => bc_hash[:public], :tag_strings => bc_hash[:tag_string], :user => u)
  end
end
