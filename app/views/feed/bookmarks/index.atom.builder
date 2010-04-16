atom_feed(:root_url => root_url, :url => request.url, :id => root_url) do |feed|
  feed.title("#{h(@title)} - #{h(Admin::Setting.abbr_app_title(current_tenant))}")
  unless @bookmarks.empty?
    feed.updated(@bookmarks.first.created_at)

    @bookmarks.each do |post|
      feed.entry(
        post,
        :url => post.escaped_url,
        :published => post.created_at,
        :updated => post.bookmark_comments.last.updated_at
      ) do |entry|
        entry.title(h(post.title))
        bookmark_comment = post.bookmark_comments.last
        entry.content(h(bookmark_comment.comment), :type => "html")
        entry.author do |author|
          author.name(h(bookmark_comment.user.name))
        end
      end
    end
  end
end
