class Feed::BookmarksController < Feed::ApplicationController
  def index
    @bookmarks = current_tenant.bookmarks.updated_at_gt(Time.now.ago(10.day)).descend_by_updated_at.publicated.limit(25)
    if @bookmarks.empty?
      head :not_found
      return
    end
    @title = _('New bookmarks')
    respond_to do |format|
      format.rss { render :action => 'index.rxml' }
      format.atom { render :action => 'index' }
    end
  end
end
