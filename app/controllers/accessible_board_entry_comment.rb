module AccessibleBoardEntryComment
  def current_target_comment
    @board_entry_comment ||= BoardEntryComment.find(params[:id])
  end

  def required_full_accessible_comment board_entry_comment = current_target_comment
    if result = board_entry_comment.full_accessible?(current_user)
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
