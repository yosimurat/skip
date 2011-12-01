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

module ThankyousHelper
  def thankyou_link_to receive_user
    if receive_user != current_user && receive_user.active?
       link_to(icon_tag('thumb_up') + Thankyou.thankyou_label, 'javascript:void(0);', :data_receiver_id => "#{receive_user.id}", :class => 'btn_blue', :onclick => "$j('#thankyou_dialog').find('#thankyou_receiver_id').val($j(this).attr('data_receiver_id'));$j('#thankyou_dialog').dialog('open');")
    end
  end
end
