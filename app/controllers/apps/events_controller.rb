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

  %w(index new create show edit update attend absent).each do |method_name|
    define_method method_name do
      client = HTTPClient.new

      apps_url = "http://localhost:4000#{request.path}"
      common_headers = {'CsrfToken' => form_authenticity_token, 'SkipUserId' => current_user.id}
      body =
        if request.get?
          client.get_content(apps_url, request.request_parameters, common_headers)
        else
          client.post_content(apps_url, request.request_parameters.to_json, common_headers.merge({'Content-Type' => 'application/json'}))
        end

      respond_to do |format|
        format.html { render :text => body, :layout => true }
      end
    end
  end

private
  def setup_layout
    @main_menu = @title = _('Events')
  end
end
