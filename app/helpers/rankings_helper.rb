module RankingsHelper
  def ranking_title contents_type
    case contents_type
    when :entry_access
      _("Ranking of Popular Blogs (Access)")
    when :entry_comment
      _("Ranking of Popular Blogs (Comments)")
    when :entry_he
     _("Ranking of Popular Blogs (%s)") % h(_(Admin::Setting.point_button(current_tenant)))
    when :user_access
      _("Ranking of Popular Users (Access)")
    when :user_entry
      _("Ranking of Popular Users (Blog Entries Posted)")
    when :commentator
      _("Ranking of Popular Users (Comments Posted)")
    else
      ""
    end
  end

  def ranking_caption contents_type
    case contents_type
    when :entry_access
      _("Most read blog / forum entries (public entries only)")
    when :entry_comment
      _("Entries most commented (public entries only)")
    when :entry_he
      _("Blog / forum entries got most %s from others (public entries only)") % h(_(Admin::Setting.point_button(current_tenant)))
    when :user_access
      _("Users got most access to his / her entries and profile.")
    when :user_entry
      _("Users posted most blog entries (disregarding the publicity)")
    when :commentator
      _("Users made most comments (disregarding the publicity)")
    else
      ""
    end
  end

  def ranking_amount_name contents_type
    case contents_type
    when :entry_access
      _("Access Count")
    when :entry_comment
      _("Comment Count")
    when :entry_he
      h(_(Admin::Setting.point_button(current_tenant)))
    when :user_access
      _("Access Count")
    when :user_entry
      _("Blog Entry Count")
    when :commentator
      _("Comment Count")
    else
      ""
    end
  end

  def show_title_col? contents_type
    ranking_data_type(contents_type).to_s == "entry"
  end

  def ranking_data_type contents_type
    case contents_type
    when :entry_access
      "entry"
    when :entry_comment
      "entry"
    when :entry_he
      "entry"
    when :user_access
      "user"
    when :user_entry
      "user"
    when  :commentator
      "user"
    else
      ""
    end
  end

  def ranking_list_of_month(dates)
    dates.map do |date|
      year, month = date.split("-")
      [date, polymorphic_path([current_tenant, :rankings], :action => :monthly, :year => year.to_i, :month => month.to_i)]
    end
  end

end
