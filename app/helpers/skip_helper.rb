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

module SkipHelper

  # （images/skip以下に格納されている）画像を参照する
  def skip_image_tag(source, options = {})
    url = "/images/skip/#{source}"
    return options[:only_url] ? url : image_tag(url, options)
  end

  def link_to_hiki_help
    sub_window_script = get_subwindow_script "#{tenant_root_url(tenant_root_url)}hiki.html", 500, 600
    link_to _('[Hints on writing entries]'), "javascript:void(0)", :onclick => "#{sub_window_script}"
  end

  def get_subwindow_script url, width, height, title='subwindow'
    "sub_window = window.open('#{url}', title, 'width=#{width},height=#{height},resizable=yes,scrollbars=yes');sub_window.focus();"
  end

  # バリデーションエラーメッセージのテンプレートを置換する
  # app/views/system/_error_messages_for.rhtml が存在する前提
  def template_error_messages_for (object_name_or_messages, options = {})
    options = options.symbolize_keys
    messages =
      if object_name_or_messages.is_a?(Array)
        object_name_or_messages
      elsif object_name_or_messages.is_a?(String)
        instance = instance_variable_get("@#{object_name_or_messages}")
        instance.errors.full_messages
      end || []
    unless messages.empty?
      render :partial => "system/error_messages_for",
      :locals=> { :messages=> messages }
    end
  end

  # Google Analytics
  def google_analytics_tag
    unless (ga_code = GlobalInitialSetting['google_analytics']).blank?
    <<-EOS
<script type="text/javascript">
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
var pageTracker = _gat._getTracker("#{ga_code}");
pageTracker._initData();
pageTracker._trackPageview();
</script>
    EOS
    end
  end
end
