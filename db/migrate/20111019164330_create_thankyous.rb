class CreateThankyous < ActiveRecord::Migration
  def self.up
    create_table :thankyous do |t|
      t.integer :receiver_id
      t.integer :sender_id
      t.string :comment, :limit => 1000, :default => ''

      t.timestamps
    end
    add_index :thankyous, :receiver_id
    add_index :thankyous, :sender_id
  end

  def self.down
    drop_table :thankyous
  end
end
