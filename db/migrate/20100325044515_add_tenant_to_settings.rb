class AddTenantToSettings < ActiveRecord::Migration
  def self.up
    change_table :settings do |t|
      t.references :tenant, :null => false
      t.index :tenant_id
    end
  end

  def self.down
    change_table :settings do |t|
      t.remove_references :tenant
    end
  end
end
