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

class Group < ActiveRecord::Base
  include SkipEmbedded::LogicalDestroyable
  include Search::Indexable

  belongs_to :tenant
  belongs_to :group_category
  has_many :group_participations, :dependent => :destroy
  has_many :users, :through => :group_participations, :conditions => ['group_participations.waiting = ?', false]
  has_many :owner_entries, :class_name => 'BoardEntry', :as => :owner, :dependent => :destroy
  has_many :owner_share_files, :class_name => 'ShareFile', :as => :owner, :dependent => :destroy

  validates_presence_of :name, :description, :gid, :tenant_id
  validates_uniqueness_of :gid, :case_sensitive => false
  validates_length_of :gid, :within => 4..50
  validates_format_of :gid, :message => _("accepts numbers, alphabets, hiphens(\"-\") and underscores(\"_\")."), :with => /^[a-zA-Z0-9\-_]*$/
  validates_inclusion_of :default_publication_type, :in => ['public', 'private']

  named_scope :partial_match_gid, proc {|word|
    {:conditions => ["gid LIKE ?", SkipUtil.to_lqs(word)]}
  }

  named_scope :partial_match_gid_or_name, proc {|word|
    {:conditions => ["gid LIKE ? OR name LIKE ?", SkipUtil.to_lqs(word), SkipUtil.to_lqs(word)]}
  }

  named_scope :partial_match_name_or_description, proc {|word|
    return {} if word.blank?
    {:conditions => ["name LIKE ? OR description LIKE ?", SkipUtil.to_lqs(word), SkipUtil.to_lqs(word)]}
  }

  named_scope :categorized, proc {|category_id|
    return {} if category_id.blank? || category_id == 'all'
    {:conditions => ['group_category_id = ?', category_id]}
  }

  # TODO joinedにリネームする
  named_scope :participating, proc {|user|
    return {} unless user
    {
      :conditions => ["group_participations.user_id = ? AND group_participations.waiting = 0", user.id],
      :include => [:group_participations]
    }
  }

  named_scope :unjoin, proc {|user|
    return {} unless user
    join_group_ids =
      if user.is_a?(User)
        Group.participating(user).map(&:id)
      elsif user.is_a?(Integer)
        Group.participating(User.find(user)).map(&:id)
      end
    return {} if join_group_ids.blank?
    {:conditions => ["groups.id NOT IN (?)", join_group_ids]}
  }

  named_scope :owned, proc { |user|
    {:conditions => ["group_participations.user_id = ? AND group_participations.owned = 1", user.id], :include => :group_participations}
  }

  named_scope :has_waiting_for_approval, proc {
    {
      :conditions => ["group_participations.waiting = 1"],
      :include => [:group_participations]
    }
  }

  named_scope :recent, proc { |day_count|
    { :conditions => ['created_on > ?', Time.now.ago(day_count.to_i.day)] }
  }

  named_scope :group_category_id_is, proc { |group_category_ids|
    return {} if (group_category_ids.blank? || group_category_ids == 'all')
    { :conditions => ['group_category_id IN (?)', [group_category_ids].flatten] }
  }

  named_scope :order_participate_recent, proc {
    { :order => "group_participations.created_on DESC" }
  }

  named_scope :order_recent, proc { { :order => 'groups.created_on DESC' } }

  named_scope :order_active, proc {
    {
      :include => :owner_entries, :group => 'groups.id', :order => 'MAX(board_entries.updated_on) DESC'
    }
  }

  named_scope :limit, proc { |num| { :limit => num } }

  N_('Group|Protected|true')
  N_('Group|Protected|false')

  # TODO これだとfind等のたびに評価される。GroupsController#new, create等の時のみ個別に対応する方がいいかも
  def after_initialize
    unless group_category_id
      if gc = tenant.group_categories.find_by_initial_selected(true)
        group_category_id = gc.id
      end
    end
  end

  def after_save
    if protected_was == true and protected == false
      self.group_participations.waiting.each{ |p| p.update_attributes(:waiting => false)}
    end
  end

  # グループに関連する情報の削除
  def after_logical_destroy
    owner_entries.destroy_all
    owner_share_files.destroy_all
  end

  def validate
    unless tenant.group_categories.find_by_id(self.group_category_id)
      errors.add(:group_category_id, _('Category not selected or value invalid.'))
    end
  end

  def self.has_waiting_for_approval owner
    Group.active.owned(owner) & Group.active.has_waiting_for_approval
  end

  # グループのカテゴリごとのgidの配列を返す(SQL発行あり)
  #   { "BIZ" => ["gid:swat","gid:qms"], "LIFE" => [] ... }
  def self.gid_by_category
    group_by_category = Hash.new{|h, key| h[key] = []}
    active(:select => "group_category_id, gid").each{ |group| group_by_category[group.group_category_id] << "gid:#{group.gid}" }
    group_by_category
  end

  def joined? target_user
    GroupParticipation.joined?(target_user, self)
  end

  def owned? target_user
    GroupParticipation.owned?(target_user, self)
  end

  def owners
    group_participations.active.only_owned.order_new.map(&:user)
  end

  def administrator?(user)
    Group.owned(user).participating(user).map(&:id).include?(self.id)
  end

  def to_s
    return 'id:' + id.to_s + ', name:' + name.to_s
  end

  def to_draft uri
    body_lines = []
    body_lines << ERB::Util.h(self.name)
    body_lines << ERB::Util.h(self.description)

<<-DRAFT
@uri=#{uri}
@title=#{ERB::Util.h(self.name)}
@cdate=#{self.created_on.rfc822}
@mdate=#{self.updated_on.rfc822}
@aid=skip
@object_type=#{self.class.table_name.singularize}
@object_id=#{self.id}

#{body_lines.join("\n")}
DRAFT
  end

end
