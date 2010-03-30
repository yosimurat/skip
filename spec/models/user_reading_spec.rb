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

require File.dirname(__FILE__) + '/../spec_helper'

describe UserReading, '.be_read_too_old_entries' do
  before do
    BoardEntry.record_timestamps = false
    UserReading.delete_all
    create_user_reading(:board_entry => create_board_entry(:updated_on => Time.now.ago(6.month)), :read => false)
    create_user_reading(:board_entry => create_board_entry(:updated_on => Time.now.ago(4.month)), :read => false)
    create_user_reading(:board_entry => create_board_entry(:updated_on => Time.now.ago(2.month)), :read => false)
  end
  describe '月指定しない場合' do
    subject {
      UserReading.be_read_too_old_entries
    }
    it '3ヶ月前以前の未読レコードのみ更新されること' do
      should == 2
    end
  end
  describe '5ヶ月前で指定する場合' do
    subject {
      UserReading.be_read_too_old_entries(:month_before => 5)
    }
    it '5ヶ月前以前の未読レコードのみ更新されること' do
      should == 1
    end
  end
  after do
    BoardEntry.record_timestamps = true
  end
end
