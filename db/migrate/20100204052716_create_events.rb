class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string    "title",        :null => false
      t.text      "description"
      t.datetime  "start_date"
      t.datetime  "end_date"
      t.boolean   "public",       :default => true,       :null => false
      t.integer   "creator_id",   :null => false
    end

    create_table :event_attendees do |t|
      t.integer   "event_id",     :null => false
      t.integer   "user_id",      :null => false
      t.string    "status",       :default => "uninput",  :null => false
      t.text      "comment"
    end
  end

  def self.down
    drop_table :events
    drop_table :event_attendees
  end
end
