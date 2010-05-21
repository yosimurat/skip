class GroupParticipationsController < ApplicationController
  include AccessibleGroup
  before_filter :target_group_required
  before_filter :target_user_required, :only => %w(create)
  before_filter :required_full_accessible_group, :only => %w(manage_members add_admin_control remove_admin_control approve disapprove)
  before_filter :required_full_accessible_group_participation, :only => %w(destroy)

  def new
    search_params = params[:search] ||= {}
    if group = current_tenant.groups.find_by_id(params[:joined_group_id])
      search_params[:id_equals_any] = group.group_participations.active.map(&:user_id)
    end
    @search = current_tenant.users.descend_by_user_access_last_access.search(search_params)
    @search.exclude_retired = '1'

    @users = @search.paginate({:include => %w(user_access), :page => params[:page]})
  end

  def create
    group = current_target_group
    group_participation = GroupParticipation.find_or_initialize_by_group_id_and_user_id(group.id, current_target_user.id)
    group_participation.user = current_target_user

    required_full_accessible_group_participation(group_participation) do
      group_participation.join!(current_user) do |result, participation, messages|
        if result
          flash[:notice] = messages
        else
          flash[:error] = messages
        end
      end
      respond_to do |format|
        format.html do
          if current_target_user.id == current_user.id
            redirect_to [current_tenant, group]
          else
            redirect_to new_polymorphic_path([current_tenant, group, :group_participation])
          end
        end
      end
    end
  end

  def multi_create
    group = current_target_group
    if params[:user_ids] && params[:user_ids].is_a?(Array)
      group_participations = current_tenant.users.id_is(params[:user_ids]).map do |target_user|
        group_participation = GroupParticipation.find_or_initialize_by_group_id_and_user_id(group.id, target_user.id)
        group_participation.user = target_user
        unless group_participation.full_accessible?(current_user)
          respond_to do |format|
            format.html { redirect_to_with_deny_auth }
            format.js { render :text => _('Operation unauthorized.'), :status => :forbidden }
            return
          end
        end
        group_participation
      end
      success_messages = []
      fail_messages = []
      group_participations.each do |group_participation|
        group_participation.join!(current_user) do |result, participation, messages|
          if result
            success_messages << messages
          else
            fail_messages << messages
          end
        end
      end
      flash[:notice] = success_messages.join("\n") unless success_messages.empty?
      flash[:error] = fail_messages.join("\n") unless fail_messages.empty?
      respond_to do |format|
        format.html do
          redirect_to new_polymorphic_path([current_tenant, group, :group_participation])
        end
      end
    else
      flash[:error] = _("Invalid parameter(s) detected.")
      respond_to do |format|
        format.html do
          redirect_to new_polymorphic_path([current_tenant, group, :group_participation])
        end
      end
    end
  end

  def destroy
    group = current_target_group
    current_target_group_participation.leave(current_user) do |result, participation, messages|
      if result
        flash[:notice] = messages
      else
        flash[:error] = messages
      end
    end
    respond_to do |format|
      format.html do
        if current_target_group_participation.user.id == current_user.id
          redirect_to [current_tenant, group]
        else
          redirect_to polymorphic_url([current_tenant, group, :group_participations], :action => :manage_members)
        end
      end
    end
  end

  def manage_members
    @participations = current_target_group.group_participations.active.paginate(:page => params[:page], :per_page => 20)
  end

  def add_admin_control
    current_target_group_participation.owned = true
    current_target_group_participation.save
    respond_to do |format|
      format.html { redirect_to polymorphic_path([current_tenant, current_target_group, :group_participations], :action => :manage_members) }
    end
  end

  def remove_admin_control
    current_target_group_participation.owned = false
    current_target_group_participation.save
    respond_to do |format|
      format.html { redirect_to polymorphic_path([current_tenant, current_target_group, :group_participations], :action => :manage_members) }
    end
  end

  def manage_waiting_members
    @participations = current_target_group.group_participations.waiting.paginate(:page => params[:page], :per_page => 20)
  end

  def approve
    group = current_target_group
    current_target_group_participation.waiting = false
    current_target_group_participation.save
    unless current_target_group_participation.user.notices.find_by_target_id(group.id)
      current_target_group_participation.user.notices.create!(:target => group)
    end
    SystemMessage.create_message :message_type => 'APPROVAL_OF_JOIN', :user_id => current_target_group_participation.user.id, :message_hash => {:group_id => group.id}
    respond_to do |format|
      format.html do
        flash[:notice] = _("Succeeded to approve.")
        redirect_to polymorphic_path([current_tenant, current_target_group, :group_participations], :action => :manage_waiting_members)
      end
    end
  end

  def disapprove
    group = current_target_group
    current_target_group_participation.destroy
    SystemMessage.create_message :message_type => 'DISAPPROVAL_OF_JOIN', :user_id => current_target_group_participation.user.id, :message_hash => {:group_id => group.id}
    respond_to do |format|
      format.html do
        flash[:notice] = _("Succeeded to disapprove.")
        redirect_to polymorphic_path([current_tenant, current_target_group, :group_participations], :action => :manage_waiting_members)
      end
    end
  end

  private
  def current_target_group_participation
    @current_target_group_participation ||= current_target_group.group_participations.find params[:id]
  end

  def required_full_accessible_group_participation group_participation = current_target_group_participation
    if result = group_participation.full_accessible?(current_user)
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
