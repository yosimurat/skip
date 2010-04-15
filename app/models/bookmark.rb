require 'uri'
require 'open-uri'
require "resolv-replace"
require 'timeout'
# FIXME 内部URL用のvalidationが必要
class Bookmark < ActiveRecord::Base
  belongs_to :tenant
  has_many :bookmark_comments, :dependent => :destroy

  validates_presence_of :tenant

  validates_presence_of :url
  validates_length_of :url, :maximum => 255
  validates_uniqueness_of :url, :scope => :tenant_id
  validates_format_of :url, :message =>_('needs to be in "http(or https)://..." format.'), :with => URI.regexp, :if => :is_type_internet?

  validates_presence_of :title
  validates_length_of :title, :maximum => 255

  accepts_nested_attributes_for :bookmark_comments

  attr_accessor :escaped_url

  named_scope :tagged, proc { |tag_words, tag_select|
    return {} if tag_words.blank?
    tag_select = 'AND' unless tag_select == 'OR'
    condition_str = ''
    condition_params = []
    words = tag_words.split(',')
    words.each do |word|
      condition_str << (word == words.last ? ' bookmarks.tag_strings like ?' : " bookmarks.tag_strings like ? #{tag_select}")
      condition_params << SkipUtil.to_like_query_string(word)
    end
    { :conditions => [condition_str, condition_params].flatten }
  }

  named_scope :order_sort_type, proc { |sort_type|
    case sort_type
    when "date_desc" then descend_by_updated_at.proxy_options
    when "date_asc" then ascend_by_updated_at.proxy_options
    when "bookmark_comments_count" then descend_by_bookmark_comments_count.proxy_options
    end
  }

  # FIXME URLのLIKE検索ではなくて、ブックマーク種別のようなカラムを追加するべき
  named_scope :bookmark_type, proc { |type|
    case type
    when "all" then {}
    when "board_entry" then url_like("/board_entries/%").proxy_options
    when "internet" then url_like("http%").proxy_options
    end
  }

#  named_scope :recent, proc { |day_count|
#    return {} if day_count.blank?
#    { :conditions => ["bookmarks.updated_on > ?", Time.now.ago(day_count.to_i.day)] }
#  }
#
  named_scope :publicated, proc {
    {
      :select => 'distinct bookmarks.*',
      :conditions => ['bookmark_comments.public = ?', true],
      :include => [:bookmark_comments]
    }
  }
#
#  named_scope :order_new, proc { { :order => "bookmarks.updated_on DESC" } }
#
  named_scope :limit, proc { |num| { :limit => num } }
#
#  SORT_TYPES = [
#    [ N_("Sort by Registered Dates (Descending)"), "bookmarks.updated_on DESC" ],
#    [ N_("Sort by Registered Dates (Ascending)"), "bookmarks.updated_on ASC" ],
#    [ N_("Sort by number of users"), "bookmark_comments_count DESC"]
#  ].freeze
#
  GET_TITLE_TIMEOUT = 7

  class InvalidMultiByteURIError < RuntimeError;end

#
  def self.get_title_from_url url
    begin
      timeout(GET_TITLE_TIMEOUT) do
        open(url, :proxy => GlobalInitialSetting['proxy_url']) do |f|
          f.each_line do |line|
            return $2.toutf8 if /<(title|TITLE)>(.*?)<\/(title|TITLE)>/.match(line)
          end
        end
      end
    rescue Exception => ex
      logger.error "[GET TITLE ERROR] #{ex.class}: #{ex.message}"
    end
    ""
  end
#
#  def self.make_conditions(options={ })
#    condition_param = []
#    condition_state = "bookmark_comments_count > 0 AND bookmark_comments.public = true "
#
#    if options[:title]
#      condition_state << " and title like ?"
#      condition_param << SkipUtil.to_like_query_string(options[:title])
#    end
#
#    if options[:tag_words] && options[:tag_select]
#      words = options[:tag_words].split(',')
#      if options[:tag_select] == "AND"
#        words.each do |word|
#          condition_state << " and bookmark_comments.tags like ?"
#          condition_param << SkipUtil.to_like_query_string(word)
#        end
#      else
#        words.each do |word|
#          condition_state << " and (" if word == words.first
#          condition_state << " bookmark_comments.tags like ? OR" if word != words.last
#          condition_state << " bookmark_comments.tags like ?)" if word == words.last
#          condition_param << SkipUtil.to_like_query_string(word)
#        end
#      end
#    end
#
#    if options[:type] and options[:type] != 'all'
#     condition_state << " and url like ?"
#     condition_param << Bookmark.get_query_param(options[:type])
#    end
#
#    return condition_param.unshift(condition_state)
#  end
#
  def is_type_page?
    self.url.index("/board_entries/") == 0
  end

  def is_type_internet?
    self.url.index("http://") == 0 || self.url.index("https://") == 0
  end

  def escaped_url
    unless @escaped_url
      URI.unescape(url).unpack('U*')
      @escaped_url = URI.escape(URI.escape(url), "'")
    end
    @escaped_url
  rescue ArgumentError => e
    self.url = 'invalid_url'
  end

  def self.unescaped_url url
    returning u = URI.unescape(url) do
      u.unpack('U*')
    end
  rescue ArgumentError => e
    raise Bookmark::InvalidMultiByteURIError.new(e.message)
  end

  def title
    URI.unescape(url).unpack('U*')
    read_attribute(:title)
  rescue ArgumentError => e
    write_attribute(:title, _('invalid url'))
  end
#
#  # ブックマークされたURLが全公開であるか
#  # 全公開でない記事のときfalse
#  def url_is_public?
#    return true unless is_type_page?
#
#    entry_id = url.split('/')[2]
#    entry = BoardEntry.find_by_id(entry_id)
#    return entry.public?
#  end
#
#  def self.get_query_param bookmark_type
#    case bookmark_type
#    when "user"
#      "/user/%"
#    when "page"
#      "/page/%"
#    when "internet"
#      "http%"
#    end
#  end
#
#  def tags_as_string
#    tags = []
#    bookmark_comments.each do |comment|
#      tags.concat(Tag.split_tags(comment.tags))
#    end
#    tag_str =  tags.uniq.join('][')
#    return tags.size > 0 ? "[#{tag_str}]" :""
#  end
#
  def user_tags
    @user_tags ||= BookmarkComment.get_tagcloud_tags(self.url).map(&:name)
  end

  def other_tags
    @other_tags ||= BookmarkComment.get_bookmark_tags.map(&:name) - user_tags
  end

  def your_tags user
    @your_tags ||= BookmarkComment.get_tags(user.id, 20).map(&:name) - (user_tags + other_tags)
  end
end
