class CreateTrends < ActiveRecord::Migration
  def self.up
    create_table :trends do |t|
      t.datetime :begin_of_month

      t.integer :blogs_entries_count,       :null => false
      t.integer :blogs_comments_count,      :null => false
      t.integer :blogs_points_count,        :null => false
      t.integer :blogs_viewers_count,       :null => false

      t.integer :questions_entries_count,   :null => false
      t.integer :questions_comments_count,  :null => false
      t.integer :questions_points_count,    :null => false
      t.integer :questions_viewers_count,   :null => false

      t.integer :bookmarks_count,           :null => false

      t.integer :full_text_search_count,    :null => false

      t.timestamps
    end

  end

  def self.down
    drop_table :trends
  end
end
