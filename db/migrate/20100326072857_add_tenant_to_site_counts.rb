class AddTenantToSiteCounts < ActiveRecord::Migration
  def self.up
    change_table :site_counts do |t|
      t.references :tenant, :null => false
      t.index :tenant_id
    end
  end

  def self.down
    change_table :site_counts do |t|
      t.remove_references :tenant
    end
  end
end
