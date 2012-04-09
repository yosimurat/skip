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

  named_scope :order_new, proc { { :order => 'created_at DESC' } }

  named_scope :limit, proc { |num| { :limit => num } }

  named_scope :user_and_type, proc { |word, type|
    Thankyou.make_scope_user_and_type(word, type)
  }

  named_scope :user_like_and_type, proc { |word, type|
    Thankyou.make_scope_user_and_type(word, type, :like)
  }

  def self.thankyou_label
    SkipEmbedded::InitialSettings['replace_name_of_thankyou'].blank? ? _('thankyou') : SkipEmbedded::InitialSettings['replace_name_of_thankyou']
  end

  def self.make_scope_user_and_type(word, type, *options)
    return { :include => [ :sender, :receiver ] } if word.blank?

    typesym = type.to_sym
    return { :include => [ :sender, :receiver ] } unless typesym == :sender or typesym == :receiver

    if options.first == :like
      conditions = ['user_uids.uid like :word OR users.name like :word', { :word => SkipUtil.to_like_query_string(word) } ]
    else
      conditions = ['user_uids.uid = :word OR users.name = :word', { :word => word } ]
    end

    { :joins => { typesym => :user_uids },
      :conditions => conditions,
      :include => [ :sender, :receiver ]
    }
  end

end
