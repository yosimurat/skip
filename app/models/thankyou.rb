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

class Thankyou < ActiveRecord::Base
  belongs_to :receiver, :class_name => 'User'
  belongs_to :sender, :class_name => 'User'

  attr_accessible :comment, :receiver_id

  validates_presence_of :receiver_id, :sender_id
  validates_length_of :comment, :maximum => 1000

  named_scope :limit, proc { |num| { :limit => num } }

  def self.thankyou_label
    SkipEmbedded::InitialSettings['replace_name_of_thankyou'].blank? ? _('thankyou') : SkipEmbedded::InitialSettings['replace_name_of_thankyou']
  end
end
