class RemoveUniqIndexFromSetting < ActiveRecord::Migration
  def self.up
    remove_index :settings, :name
    add_index :settings, :name
  end

  def self.down
    remove_index :settings, :name
    add_index :settings, :name, :unique => true
  end
end
