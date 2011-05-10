class Trend < ActiveRecord::Base

  named_scope :limit, proc { |num| { :limit => num } }

  def self.create_trend_data
    today = Date.today
    from = (today - 1.month).beginning_of_month
    to   = today.beginning_of_month

    # Blogs
    blogs = BoardEntry.aim_type_is('entry').publication_type_is('public').symbol_like('uid').created_on_gte(from).created_on_lt(to)
    result_blogs = entries_detail_info(blogs, {:from => from, :to => to})

    # Questions
    questions = BoardEntry.aim_type_is('question').publication_type_is('public').created_on_gte(from).created_on_lt(to)
    result_questions = entries_detail_info(questions, {:from => from, :to => to})

    # Bookmarks
    result_bookmarks = Bookmark.created_on_greater_than_or_equal_to(from).created_on_less_than(to).count

    # Full Text Search
    result_full_text_seach = FullTextSearchLog.created_at_gte(from).created_at_lt(to).count

    Trend.create(
      :begin_of_month           => from,
      :blogs_entries_count      => result_blogs[0],
      :blogs_comments_count     => result_blogs[1],
      :blogs_points_count       => result_blogs[2],
      :blogs_viewers_count      => result_blogs[3],
      :questions_entries_count  => result_questions[0],
      :questions_comments_count => result_questions[1],
      :questions_points_count   => result_questions[2],
      :questions_viewers_count  => result_questions[3],
      :bookmarks_count          => result_bookmarks,
      :full_text_search_count   => result_full_text_seach
    )
  end

  def self.entries_detail_info entries, options
    from = options[:from]
    to = options[:to]
    comments, viewers, points = 0, 0, 0

    entries.each do |e|
      comments += e.board_entry_comments.count
      viewers += e.entry_accesses.updated_on_gte(from).updated_on_lt(to).count
      points += e.state.created_on.between?(from.to_date, to.to_date) ? e.state.point : 0
    end
    [entries.count, comments, points, viewers]
  end
end
