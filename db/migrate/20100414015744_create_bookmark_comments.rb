class CreateBookmarkComments < ActiveRecord::Migration
  def self.up
    create_table :bookmark_comments do |t|
      t.text :comment, :null => false
      t.boolean :public, :default => true, :null => false
      t.string :tag_strings, :default => ''
      t.boolean  :stared, :default => false, :null => false

      t.references :bookmark
      t.references :user
      t.timestamps
    end

    add_index :bookmark_comments, :bookmark_id
    add_index :bookmark_comments, :user_id
  end

  def self.down
    drop_table :bookmark_comments
  end
end
