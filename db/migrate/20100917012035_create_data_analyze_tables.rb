class CreateDataAnalyzeTables < ActiveRecord::Migration
  def self.up
    create_table :full_text_search_logs do |t|
      t.string :query
      t.timestamps
    end

    create_table :profile_access_logs do |t|
      t.integer :to_user_id,    :null => false
      t.integer :from_user_id,  :null => false
      t.timestamps
    end

    create_table :login_logs do |t|
      t.references :user,     :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :full_text_search_logs
    drop_table :profile_access_logs
    drop_table :login_logs
  end
end
