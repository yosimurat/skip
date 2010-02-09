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
    attendance = event.attendees.find_by_user_id(current_user.id)

    unless attendance
      event.attendees.create(:user_id => current_user.id, :status => true, :comment => 'auto comment') #TODO:commentは画面から入力できるように
    else
      attendance.status = true
      attendance.save
    end

    respond_to do |format|
      format.html { redirect_to event_path(event) }
    end
  end

  def absent
    event = Event.find(params[:id])
    attendance = event.attendees.find_by_user_id(current_user.id)

    if attendance
      attendance.status = false
      attendance.save
    end

    respond_to do |format|
      format.html { redirect_to event_path(event) }
    end
  end
end
