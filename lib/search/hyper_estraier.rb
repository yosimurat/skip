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

module Search
  class HyperEstraier
    include SkipEstraierPure
    NO_QUERY_ERROR_MSG = "Please input search query."
    ACCESS_DENIED_ERROR_MSG = "Access denied by search node. Please contact system owner."

    attr_reader :invisible_count, :result, :error

    def self.search params, current_user
      instance = new
      instance.search params, current_user
      instance
    end

    def search params, current_user
      unless params[:query] && !SkipUtil.jstrip(params[:query]).empty?
        @error = NO_QUERY_ERROR_MSG
      else
        @result = {
          :header => { :count => -1, :start_count => 0, :end_count => 0, :prev => "", :next => "", :per_page => 10 },
          :elements => []
        }
        @per_page = (params[:per_page] || 10).to_i
        @offset = (params[:offset] || 0).to_i
        @invisible_count = 0

        node = current_user.tenant.node
        cond = self.class.get_condition(params[:query], params[:target_aid], params[:target_contents])
        if nres = node.search(cond, 1)
          @result[:header] = get_result_hash_header(nres.hint('HIT').to_i)
          @result[:elements] = get_result_hash_elements(nres, current_user)
        else
          # ノードにアクセスできない場合のみ nres は nil
          ActiveRecord::Base.logger.error "[HyperEstraier Error] Connection not found to #{t.node.instance_variable_get('@url')}"
          @error = ACCESS_DENIED_ERROR_MSG
        end
      end
    end

    def self.get_condition(query, target_aid = nil, target_contents = nil)
      cond = Condition.new
      cond.set_options Condition::SIMPLE
      cond.set_phrase(query) unless query.blank?
      # TODO 全文検索の検索対象アプリの設定はテナント毎な気がするぞ
      if target_aid and search_apps = GlobalInitialSetting['search_apps'] and search_apps[target_aid]
        cond.add_attr("@aid STREQ #{target_aid}")
        cond.add_attr("@object_type STREQ #{target_contents}") unless target_contents.blank?
      end
      cond
    end

    def get_result_hash_header(count)
      {
        :count => count,
        :start_count => @offset + 1,
        :end_count => @offset+@per_page > count ? count : @offset+@per_page,
        :prev => @offset > 0 ? "true" : "",
        :next => @offset+@per_page < count ? "true" : "",
        :per_page => @per_page
      }
    end

    def get_result_hash_elements(nres, current_user)
      (@offset...@result[:header][:end_count]).map do |i|
        rdoc = nres.get_doc(i)
        unless rdoc.nil?
          if object_type = rdoc.attr('@object_type')
            if (object_type == 'board_entry' || object_type == 'share_file')
              object = object_type.classify.constantize.find_by_id(rdoc.attr('@object_id'))
              unless (object && object.accessible?(current_user))
                @invisible_count = @invisible_count + 1
                next
              end
            end
            {
              :contents => ERB::Util.html_escape(rdoc.snippet),
              :link_url => URI.decode(rdoc.attr('@uri')),
              :title => rdoc.attr('@title')
            }
          end
        end
      end.compact
    end
  end
end
