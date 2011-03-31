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

module TrendsHelper
  def graph_of_blogs trends
    entries   = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.blogs_entries_count] }
    comments  = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.blogs_comments_count] }
    points    = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.blogs_points_count] }
    [entries, comments, points].to_json
  end

  def graph_of_questions trends
    entries   = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.questions_entries_count] }
    comments  = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.questions_comments_count] }
    points    = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.questions_points_count] }
    [entries, comments, points].to_json
  end

  def graph_of_viewers trends
    blogs     = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.blogs_viewers_count] }
    questions = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.questions_viewers_count] }
    [blogs, questions].to_json
  end

  def graph_of_bookmarks trends
    bookmarks = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.bookmarks_count] }
    [bookmarks].to_json
  end

  def graph_of_full_text_search trends
    full_text_search = trends.map{|i| [i.begin_of_month.strftime('%d-%b-%Y'), i.full_text_search_count] }
    [full_text_search].to_json
  end
end
