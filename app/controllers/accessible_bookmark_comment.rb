module AccessibleBookmarkComment
  def current_target_bookmark_comment
    if current_target_bookmark
      @bookmark_comment ||= current_target_bookmark.bookmark_comments.find(params[:id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def required_full_accessible_bookmark_comment bookmark_comment = current_target_bookmark_comment
    if result = bookmark_comment.full_accessible?(current_user)
      yield if block_given?
    else
      respond_to do |format|
        format.html { redirect_to_with_deny_auth }
        format.js { render :text => _('Operation unauthorized.'), :status => :forbidden }
      end
    end
    result
  end
end
