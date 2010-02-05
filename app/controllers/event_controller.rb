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

class EventController < ApplicationController

  helper_method :attended?

  def show
    @event = Event.find(params[:id])
  end

  def attend
    if attended? params[:id]
      flash[:notice] = _('Already attended')
    else
      if atnd = EventAttendee.find_by_event_id_and_user_id(params[:id].to_i, current_user.id)
        atnd.status = "attend"
        atnd.save
      else
        atnd = EventAttendee.new(:event_id => params[:id].to_i, :user_id => current_user.id, :status => "attend", :comment => "")
        atnd.save
      end
    end
    redirect_to event_path(params[:id])
  end

  def absent
    if attended? params[:id]
      attendee = EventAttendee.find_by_event_id_and_user_id(params[:id], current_user.id)
      attendee.status = "absent"
      attendee.save
    else
      flash[:notice] = "参加してない状態ですよー"
    end
    redirect_to event_path(params[:id])
  end

  def attended? event_id
    EventAttendee.attendance.find_by_event_id_and_user_id(event_id, current_user.id)
  end
end
