module BookmarksHelper
  def bookmark_comment_tag_search_links_tag comma_tags, options = {}
    return '' if comma_tags.blank?
    tag_links = comma_tags.split(',').map do |tag|
      link_to h(tag), {:controller => 'bookmarks', :tag_words => h(tag)}, :class => 'tag'
    end
    if max = options[:max] and max > 0
      toggle_links(tag_links, max)
    else
      tag_links.join('&nbsp;')
    end
  end

  def bookmark_type_icon bookmark
    unless bookmark.blank?
      bookmark.is_type_page? ? icon_tag('user') : icon_tag('world')
    end
  end

  def link_to_bookmark_url(bookmark, options = {})
    title = options[:title] || bookmark.title

    onclick_function = "$j.ajax({ type: 'GET', url: '#{polymorphic_url([current_tenant, :bookmarks], :action => :touch_bookmark_url)}', data: {target_url: this.href}, success: function() {}, error: function() {}, complete: function() {} });"
    if bookmark.is_type_page?
      prefix = options[:without_icon] ? "" : icon_tag('user')
      link_to "#{prefix} #{h title}", "#{relative_url_root}#{bookmark.escaped_url}", :title => title, :onclick => onclick_function
    else
      prefix = options[:without_icon] ? "" : icon_tag('world')
      link_to "#{prefix} #{h truncate(title, :length => 115)}", bookmark.escaped_url, :title => title, :onclick => onclick_function
    end
  end

  def url_for_bookmark bookmark
    [current_tenant, bookmark]
  end
end
