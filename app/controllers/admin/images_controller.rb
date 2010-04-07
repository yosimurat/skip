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

class Admin::ImagesController < Admin::ApplicationController
  N_('Admin::ImagesController|header_logo')
  N_('Admin::ImagesController|header_logo_description')

  def index
    @topics = [_(self.class.name.to_s)]
    @logo = Admin::Logo.tenant_id_is(current_tenant.id).first || Admin::Logo.new
  end
end
