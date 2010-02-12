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
    event = Event.find(params[:id])

    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_by_user_id(current_user.id)

      unless attendee
        event.attendees.create(:user_id => current_user.id, :status => true)
      else
        attendee.status = true
        attendee.save
      end
      flash[:notice] = _('Event was successfully updated.')
    else
      flash[:notice] = _('You are not allowed this operation.')
    end

    respond_to do |format|
      format.html { redirect_to event_path(event) }
    end
  end

  def absent
    event = Event.find(params[:id])
    if event.enable_attend_or_absent?(current_user)
      attendee = event.attendees.find_by_user_id(current_user.id)

      unless attendee
        event.attendees.create(:user_id => current_user.id, :status => false)
      else
        attendee.status = false
        attendee.save
      end
      flash[:notice] = _('Event was successfully updated.')
    else
      flash[:notice] = _('You are not allowed this operation.')
    end

    respond_to do |format|
      format.html { redirect_to event_path(event) }
    end
  end

  def update
    attendee = Attendee.find(params[:id])
    attendee.comment = params[:comment]
    attendee.save
    respond_to do |format|
      format.js { render :text => attendee.comment, :status => :ok }
    end
  end
end
