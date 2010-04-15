class CreateBookmarks < ActiveRecord::Migration
  def self.up
    create_table :bookmarks do |t|
      t.string :url, :default => "", :null => false
      t.string :title, :default => "", :null => false
      t.integer :bookmark_comments_count, :default => 0, :null => false

      t.references :tenant
      t.timestamps
    end
    add_index :bookmarks, :tenant_id
    add_index :bookmarks, :url
  end

  def self.down
    drop_table :bookmarks
  end
end
