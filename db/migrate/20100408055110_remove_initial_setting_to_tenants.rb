class RemoveInitialSettingToTenants < ActiveRecord::Migration
  def self.up
    remove_column :tenants, :initial_settings
  end

  def self.down
    add_column :tenants, :initial_settings, :text
  end
end
