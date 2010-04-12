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
  module Indexable
    include SkipEstraierPure
    def self.included(klass)
      klass.class_eval do
        include ActionController::UrlWriter
        default_url_options[:host] = GlobalInitialSetting['host_and_port']
        default_url_options[:protocol] = GlobalInitialSetting['protocol']
        if %w(production).include?(::Rails.env) && respond_to?(:handle_asynchronously)
          handle_asynchronously :create_index
          handle_asynchronously :update_index
          handle_asynchronously :destroy_index
        end
      end
    end

    def node
      @node ||= tenant.node
    end

    def create_index uri = polymorphic_url([self.tenant, self]), tenant = self.tenant
      if node
        node.put_doc(Document.new(self.to_draft(uri)))
      else
        logger.info "[Full text search] Failed to put document for full text search. To work full text search, setup HyperEstraier."
      end
    end

    alias :update_index :create_index

    def destroy_index uri = polymorphic_url([self.tenant, self]), tenant = self.tenant
      if node
        doc = node.get_doc_by_uri(uri)
        # Node#get_doc, get_doc_by_uriした後のDocument#idが-1になってしまう。
        # 恐らくestraierpure.rbのバグ
        # 一応回避は出来るが、、、
        # node.out_doc(doc.id)
        node.out_doc(doc.attr('@id')) if doc
      else
        logger.info "[Full text search] Failed to delete document for full text search. To work full text search, setup HyperEstraier."
      end
    end
  end
end
