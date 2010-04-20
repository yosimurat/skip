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

class GroupParticipation < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  named_scope :active, proc {
    { :conditions => { :waiting => false } }
  }

  named_scope :waiting, proc {
    { :conditions => { :waiting => true } }
  }

  named_scope :except_owned, proc {
    { :conditions => { :owned => false } }
  }

  named_scope :only_owned, proc {
    { :conditions => { :owned => true }, :include => [:user] }
  }

  named_scope :order_new, proc {
    { :order => "group_participations.updated_on DESC" }
  }

  N_('GroupParticipation|Waiting|true')
  N_('GroupParticipation|Waiting|false')
  N_('GroupParticipation|Owned|true')
  N_('GroupParticipation|Owned|false')

  def after_save
    group.update_attribute(:updated_on, Time.now) if group && !waiting?
  end

  def after_destroy
    group.update_attribute(:updated_on, Time.now) if group
  end

  # TODO 回帰テストを書く
  def self.joined?(target_user, target_group)
    !!find_by_user_id_and_group_id_and_waiting(target_user, target_group, false)
  end

  # TODO 回帰テストを書く
  def self.owned?(target_user, target_group)
    !!find_by_user_id_and_group_id_and_waiting_and_owned(target_user, target_group, false, true)
  end

  def join! current_user, options = {}
    if self.new_record?
      self.waiting = self.group.protected? && (self.user.id == current_user.id)
      # FIXME Controllerで制限をかけているが、ここでも本人もしくはグループ管理者のみに絞るvalidationをかけるべき
      self.save!
      self.user.notices.create!(:target => self.group) unless self.user.notices.find_by_target_id(self.group.id)
      create_join_system_message(current_user)
      if block_given?
        messages =
          if self.waiting?
            [ _('Request sent. Please wait for the approval.') ]
          else
            if current_user.id == self.user.id
              [ _('Joined the group successfully.') ]
            else
              [ _("Added %s as a member.") % self.user.name ]
            end
          end
        yield true, self, messages
      else
        true
      end
    else
      messages = [_("%s has already joined / applied to join this group.") % self.user.name]
      self.errors.add_to_base messages.first
      if block_given?
        yield false, self, messages
      else
        false
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    messages = [_('Joined the group failed.')]
    self.errors.add_to_base messages.first
    if block_given?
      yield false, self, messages
    else
      false
    end
  end

  # TODO 回帰テストを書く
  def leave current_user
    Group.transaction do
      if notice = self.user.notices.find_by_target_id(self.group.id)
        notice.destroy
      end
      self.destroy
      create_leave_system_message(current_user)
      if block_given?
        messages =
          if current_user.id == self.user.id
            [ _('Successfully left the group.') ]
          else
            [ _("Removed %s from members of the group.") % self.user.name ]
          end
        yield true, self, messages
      else
        true
      end
    end
  end

  # TODO 回帰テストを書く
  def full_accessible? target_user = self.user
    (target_user == self.user || self.group.owned?(target_user))
  end

  def to_s
    return '[id:' + id.to_s + ', user_id:' + user_id.to_s + ', group_id:' + group_id.to_s + ']'
  end

  private
  def create_join_system_message current_user
    messages = []
    unless self.waiting?
      if self.user.id == current_user.id
        self.group.group_participations.only_owned.each do |owner_participation|
          messages << SystemMessage.create_message(:message_type => 'JOIN', :user_id => owner_participation.user_id, :message_hash => {:group_id => group.id})
        end
      else
        messages << SystemMessage.create_message(:message_type => 'FORCED_JOIN', :user_id => self.user.id, :message_hash => {:group_id => self.group.id})
      end
    end
    messages
  end

  def create_leave_system_message current_user
    messages = []
    if self.user.id == current_user.id
      self.group.group_participations.only_owned.each do |owner_participation|
        messages << SystemMessage.create_message(:message_type => 'LEAVE', :user_id => owner_participation.user_id, :message_hash => {:user_id => current_user.id, :group_id => group.id})
      end
    else
      messages << SystemMessage.create_message(:message_type => 'FORCED_LEAVE', :user_id => self.user.id, :message_hash => {:group_id => group.id})
    end
    messages
  end
end
