class DropUserOauthAccesses < ActiveRecord::Migration
  def self.up
    drop_table :user_oauth_accesses
  end

  def self.down
  end
end
