class BoardEntryCommentsController < ApplicationController
  include AccessibleBoardEntry
  include AccessibleBoardEntryComment
  before_filter :required_accessible_entry, :only => %w(create)
  before_filter :required_full_accessible_comment, :only => %w(update destroy)

  def create
    @board_entry_comment = current_target_entry.board_entry_comments.build(params[:board_entry_comment])
    @board_entry_comment.user = current_user
    if @board_entry_comment.save
      unless current_target_entry.writer?(current_user.id)
        SystemMessage.create_message :message_type => 'COMMENT', :user_id => current_target_entry.user.id, :message_hash => {:board_entry_id => current_target_entry.id}
      end
      @board_entry_comment.reflect_user_readings
      @board_entry_comment.board_entry.update_index
      respond_to do |format|
        format.js { render :partial => "board_entry_comment", :locals => { :comment => @board_entry_comment } }
      end
    else
      respond_to do |format|
        format.js { render(:text => _('Failed to save the data.'), :status => :bad_request) }
      end
    end
  end

  def update
    if @board_entry_comment.update_attribute :contents, params[:board_entry_comment][:contents]
      @board_entry_comment.reflect_user_readings
      @board_entry_comment.board_entry.update_index
    end
    respond_to do |format|
      format.js { render :partial => "comment_contents", :locals =>{ :comment => @board_entry_comment } }
    end
  end

  def destroy
    if @board_entry_comment.children.size == 0
      @board_entry_comment.destroy
      @board_entry_comment.board_entry.update_index
      flash[:notice] = _("Comment was successfully deleted.")
    else
      flash[:warn] = _("This comment cannot be deleted since it has been commented.")
    end
    respond_to do |format|
      format.html do
        redirect_to [current_tenant, current_target_owner, current_target_entry]
      end
    end
  end
end
