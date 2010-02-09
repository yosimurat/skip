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

class Event < ActiveRecord::Base
  include SkipEmbedded::LogicalDestroyable

  has_many :attendees, :dependent => :destroy
  belongs_to :user

  validates_presence_of :title, :start_date

  named_scope :order_start_date, proc { { :order => 'start_date DESC' } }

  named_scope :partial_match_title_or_description, proc {|word|
    return {} if word.blank?
    {:conditions => ["title LIKE ? OR description LIKE ?", SkipUtil.to_lqs(word), SkipUtil.to_lqs(word)]}
  }

  named_scope :unhold, proc { { :conditions => ["start_date >= ?", Time.now]} }

  def enable_attend_or_absent? user
    if self.publication_type == 'public'
      return true
    elsif self.publication_type == 'protected'
      !(self.publication_symbols_value.split(',') & user.belong_symbols).blank?
    end
  end

end
