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

class AttendeesController < ApplicationController

  def attend
    event = Event.find(params[:event_id])

    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_or_initialize_by_user_id(current_user.id)
      attendee.status = true
      attendee.save
      flash[:notice] = _('Event was successfully updated.')
    else
      flash[:notice] = _('You are not allowed this operation.')
    end

    respond_to do |format|
      format.html { redirect_to event_url(event) }
    end
  end

  def absent
    event = Event.find(params[:event_id])
    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_or_initialize_by_user_id(current_user.id)
      attendee.status = false
      attendee.save
      flash[:notice] = _('Event was successfully updated.')
    else
      flash[:notice] = _('You are not allowed this operation.')
    end

    respond_to do |format|
      format.html { redirect_to event_url(event) }
    end
  end

  def update
    attendee = Attendee.find(params[:id])

    if attendee.user == current_user
      attendee.comment = params[:comment]
      attendee.save
    end
    respond_to do |format|
      format.js { render :text => ERB::Util.h(attendee.comment), :status => :ok }
    end
  end
end
