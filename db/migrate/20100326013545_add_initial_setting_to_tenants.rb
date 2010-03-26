class AddInitialSettingToTenants < ActiveRecord::Migration
  def self.up
    add_column :tenants, :initial_settings, :text
  end

  def self.down
    remove_column :tenants, :initial_settings
  end
end
