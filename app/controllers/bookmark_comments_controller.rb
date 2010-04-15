class BookmarkCommentsController < ApplicationController
  include AccessibleBookmarkComment

  before_filter :required_full_accessible_bookmark_comment
  def destroy
    @bookmark_comment.destroy
    flash[:notice] = _('Deletion completed.')
    respond_to do |format|
      format.html { redirect_to  [current_tenant, :bookmarks] }
    end
  end
end
