class CreateRankings < ActiveRecord::Migration
  def self.up
    create_table :rankings do |t|
      t.string   :url,           :null => false
      t.string   :title,         :null => false
      t.string   :author
      t.string   :author_url
      t.date     :extracted_on,  :null => false
      t.integer  :amount
      t.string   :contents_type, :null => false

      t.references :tenant
      t.timestamps
    end

    add_index(:rankings, [ :tenant_id, :contents_type, :extracted_on, :url, :amount ], :name => :main)
  end

  def self.down
    drop_table :rankings
  end
end
