class BookmarkCommentsController < ApplicationController
  before_filter :require_bookmark_enabled

  def create
    bookmark = Bookmark.find params[:bookmark_id]
    bookmark_comment = bookmark.bookmark_comments.build params[:bookmark_comment]
    bookmark_comment.public = true
    bookmark_comment.user_id = current_user.id
    respond_to do |format|
      format.html do
        if bookmark_comment.save
          flash[:notice] = _('%{model} was successfully created.') % {:model => _('bookmark comment')}
          redirect_to polymorphic_url([:bookmarks], :anchor => 'search_result')
        else
          flash[:error] = 'Failed to save the data'
          redirect_to root_url
        end
      end
    end
  end
end
