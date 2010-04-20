class RemoveGidFromGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups, :gid
  end

  def self.down
    raise IrreversibleMigration
  end
end
