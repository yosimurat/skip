class AddParentIdOnBoardEntries < ActiveRecord::Migration
  def self.up
    add_column :board_entries, :parent_id, :integer, :default => nil
  end

  def self.down
    remove_column :board_entries, :parent_id
  end
end
