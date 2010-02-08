class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string      "title",        :null => false
      t.text        "description"
      t.datetime    "start_date"
      t.datetime    "end_date"
      t.boolean     "publication",  :default => true,       :null => false
      t.references  "user",         :null => false
      t.timestamps

      t.index       "user"
    end

    create_table :attendees do |t|
      t.references    "event",        :null => false
      t.references    "user",         :null => false
      t.string        "status",       :default => "uninput",  :null => false
      t.string        "comment"
      t.timestamps

      t.index         "event"
      t.index         "user"
    end
  end

  def self.down
    drop_table :events
    drop_table :attendees
  end
end
