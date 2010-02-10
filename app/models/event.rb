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

  named_scope :recent, proc { |day_count|
    { :conditions => ['created_at > ?', Time.now.ago(day_count.to_i.day)] }
  }

  named_scope :order_recent, proc { { :order => 'created_at DESC' } }

  named_scope :limit, proc { |num| { :limit => num } }

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

  def uninput_members
    uninput_users = []
    inputed_users = []
    self.publication_symbols_value.split(',').each do |sym|
      symbol_type, symbol_id = SkipUtil.split_symbol(sym)
      case symbol_type
      when "uid"
        uninput_users << User.active.find_by_uid(symbol_id)
      when "gid"
        group = Group.active.find_by_gid(symbol_id, :include => [:group_participations])
        uninput_users << group.group_participations.map { |part| part.user if part.user.active? } if group
      end
    end

    self.attendees.each { |attendee| inputed_users << attendee.user }

    uninput_users.flatten.uniq.compact - inputed_users.flatten.uniq.compact
  end

end
