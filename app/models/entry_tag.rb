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

class EntryTag < ActiveRecord::Base
  belongs_to :board_entry
  belongs_to :tag

  named_scope :tenant_is, proc { |tenant|
    # 指定したtenantに直接紐づいてないのでEXISTS句を利用して対象テナントに存在するレコードのみを検索対象にしている
    {:conditions => "EXISTS (SELECT * FROM board_entries WHERE board_entries.tenant_id = #{tenant.id} AND entry_tags.board_entry_id = board_entries.id)" }
  }
end
