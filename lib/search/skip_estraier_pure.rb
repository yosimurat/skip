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

require "estraierpure"

module Search
  module SkipEstraierPure
    include EstraierPure
    class Node < EstraierPure::Node
      def inform
        @status = -1
        return false unless @url
        turl = @url + "/inform"
        reqheads = [ "Content-Type: application/x-www-form-urlencoded" ]
        reqheads.push("Authorization: Basic " + EstraierPure::Utility::base_encode(@auth)) if @auth
        rv = EstraierPure::Utility::shuttle_url(turl, @pxhost, @pxport, @timeout, reqheads, "", nil, nil)
        @status = rv
        rv == 200
      end

      def create name, label = nil
        label = name unless label
        @status = -1
        return false unless @base_url
        turl = URI.join(@base_url, 'master').to_s + "?action=nodeadd&name=#{name}&label=#{label}"
        reqheads = [ "Content-Type: application/x-www-form-urlencoded" ]
        reqheads.push("Authorization: Basic " + EstraierPure::Utility::base_encode(@auth)) if @auth
        rv = EstraierPure::Utility::shuttle_url(turl, @pxhost, @pxport, @timeout, reqheads, nil, nil, nil)
        @status = rv
        rv == 200
      end

      def clear name = self.name
        @status = -1
        return false unless @base_url
        turl = URI.join(@base_url, 'master').to_s + "?action=nodeclr&name=#{name}"
        reqheads = [ "Content-Type: application/x-www-form-urlencoded" ]
        reqheads.push("Authorization: Basic " + EstraierPure::Utility::base_encode(@auth)) if @auth
        rv = EstraierPure::Utility::shuttle_url(turl, @pxhost, @pxport, @timeout, reqheads, nil, nil, nil)
        @status = rv
        rv == 200
      end

      def new_record?
        !inform
      end

      def self.find_or_initialize_by_url base_url, node_name, auth_id, auth_password
        node = new(base_url, node_name, auth_id, auth_password)
        if node.new_record?
          node.create(node_name) ? node : nil
        else
          node
        end
      end

      private
      def initialize base_url = nil, node_name = nil, auth_id = nil, auth_password = nil
        super()
        if (base_url && node_name)
          @base_url = base_url
          self.set_url(URI.join(base_url, 'node/', node_name).to_s)
        end
        self.set_auth(auth_id, auth_password) if (auth_id && auth_password)
      end
    end
  end
end
