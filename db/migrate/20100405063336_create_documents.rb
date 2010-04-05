class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string :name, :null => false
      t.text :value, :null => false, :default => ''

      t.timestamps

      t.references :tenant
    end

    add_index :documents, :tenant_id
  end

  def self.down
    drop_table :documents
  end
end
