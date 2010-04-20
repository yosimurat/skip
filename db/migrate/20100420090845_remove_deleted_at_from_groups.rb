class RemoveDeletedAtFromGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups, :deleted_at
  end

  def self.down
    raise IrreversibleMigration
  end
end
