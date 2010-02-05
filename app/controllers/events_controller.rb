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

class EventsController < ApplicationController
  before_filter :setup_layout

  verify :method => :post, :only => [ :create ],
          :redirect_to => { :action => :index }

  def index
    @events = Event.all.paginate(:page => params[:page], :per_page => 50)
  end

private
  def setup_layout
    @main_menu = @title = _('Events')
  end
end
