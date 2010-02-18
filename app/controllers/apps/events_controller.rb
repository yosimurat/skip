# SKIP(Social Knowledge & Innovation Platform)
# Copyright (C) 2008-2010 TIS Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

class Apps::EventsController < Apps::ApplicationController
  before_filter :setup_layout

  %w(index new create).each do |method_name|
    define_method method_name do
      client = HTTPClient.new

      apps_url = "http://localhost:4000#{request.path}"
      common_headers = {'CsrfToken' => form_authenticity_token, 'SkipUserId' => current_user.id}
      body =
        if request.get?
          client.get_content(apps_url, request.request_parameters, common_headers)
        else
          client.post_content(apps_url, request.request_parameters, common_headers)
        end

      respond_to do |format|
        format.html { render :text => body, :layout => true }
      end
    end
  end

  def show
    @event = Event.find(params[:id])

    @attendees = if @event.publication_type == "public"
      @event.attendees.status_is(true).descend_by_status_and_updated_at.paginate(:page => params[:page], :per_page => 50)
    else
      @event.attendees.descend_by_status_and_updated_at.paginate(:page => params[:page], :per_page => 50)
    end

    respond_to do |format|
      format.html
    end
  end

  def edit
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.user == current_user
        format.html
      else
        flash[:notice] = _('You are not allowed this operation.')
        format.html { redirect_to event_url(@event) }
      end
    end
  end

  def update
    @event = Event.find(params[:id])
    @event.publication_symbols_value = params[:publication_symbols_value] unless params[:publication_symbols_value].blank?

    respond_to do |format|
      unless @event.user == current_user 
        flash[:notice] = _('You are not allowed this operation.')
        redirect_to event_url(@event)
      else
        if@event.update_attributes(params[:event])
          format.html do
            flash[:notice] = _('Event was updated successfully.')
            redirect_to event_url(@event)
          end
        else
          format.html { render :edit }
        end
      end
    end
  end

  def attend
    event = Event.find(params[:id])
    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_or_initialize_by_user_id(current_user.id)
      attendee.status = true
      if attendee.save
        flash[:notice] = _('Event was successfully updated.')
      else
        flash[:notice] = _('You are not allowed this operation.')
      end
    end

    respond_to do |format|
      format.html { redirect_to event_url(event) }
    end
  end

  def absent
    event = Event.find(params[:id])
    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_or_initialize_by_user_id(current_user.id)
      attendee.status = false
      if attendee.save
        flash[:notice] = _('Event was successfully updated.')
      else
        flash[:notice] = _('You are not allowed this operation.')
      end
    end

    respond_to do |format|
      format.html { redirect_to event_url(event) }
    end
  end

private
  def setup_layout
    @main_menu = @title = _('Events')
  end
end
