class CreateBookmarkCommentTags < ActiveRecord::Migration
  def self.up
    create_table :bookmark_comment_tags do |t|
      t.references :bookmark_comment
      t.references :tag
      t.timestamps
    end

    add_index :bookmark_comment_tags, :bookmark_comment_id
    add_index :bookmark_comment_tags, :tag_id
  end

  def self.down
    drop_table :bookmark_comment_tags
  end
end
