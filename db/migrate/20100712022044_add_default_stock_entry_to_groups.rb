class AddDefaultStockEntryToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :default_stock_entry, :boolean, :default => false
  end

  def self.down
    remove_column :groups, :default_stock_entry
  end
end
