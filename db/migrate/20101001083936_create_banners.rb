class CreateBanners < ActiveRecord::Migration
  def self.up
    create_table :banners do |t|
      t.string :link_url,   :null => false, :default => ''
      t.string :image_url,  :null => false, :default => ''
      t.timestamps
    end
  end

  def self.down
    drop_table :banners
  end
end
