class AddLoginToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :login
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :login
    end
  end
end
