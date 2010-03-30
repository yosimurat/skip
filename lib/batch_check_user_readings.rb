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

require File.expand_path(File.dirname(__FILE__) + "/batch_base")

class BatchCheckUserReadings < BatchBase

  def self.execute options
    check_month = options[:check_month].to_i
    UserReading.be_read_too_old_entries(:month_before => check_month)
  end

end

# シェルからパラメータを受け取って実行する部分
# num 本日よりnumヶ月前以前の未読記事を既読にする
# 実行例 ruby batch_check_user_readings.rb 3

check_month = ARGV[0] || "3"
if check_month.index(/[0-9]+/)
  BatchCheckUserReadings.execution({:check_month => check_month})
else
  BatchCheckUserReadings::log_error "数値以外の引数が指定されています。"
end
