class DropOauthProviders < ActiveRecord::Migration
  def self.up
    drop_table :oauth_providers
  end

  def self.down
    raise IrreversibleMigration
  end
end
