class RemoveNoticeTypeFromUserReadings < ActiveRecord::Migration
  def self.up
    remove_column :user_readings, :notice_type
  end

  def self.down
    raise IrreversibleMigration
  end
end
