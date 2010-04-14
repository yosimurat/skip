class BookmarkCommentTag < ActiveRecord::Base
  belongs_to :bookmark_comment
  belongs_to :tag
end
