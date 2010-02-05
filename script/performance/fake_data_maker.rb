ENV["RAILS_ENV"] = "performance_test"
require File.expand_path(File.join(File.dirname(__FILE__),'../..','config','environment'))

def rand_entry_type
  %w(DIARY GROUP_BBS)[rand(2)]
end

def rand_aim_type
  %w(entry question notice)[rand(3)]
end

earlist_time = Time.local('2007-01-01 00:00:00')
latest_time = Time.local('2009-12-31 23:55:55')

sql = "INSERT INTO `board_entries` (`created_on`, `entry_type`, `category`, `title`, `symbol`, `aim_type`, `hide`, `updated_on`, `date`, `lock_version`, `user_entry_no`, `publication_type`, `ignore_times`, `last_updated`, `contents`, `user_id`, `publication_symbols_value`, `entry_trackbacks_count`, `board_entry_comments_count`, `editor_mode`) VALUES"
#puts sql
sql <<
  (0..50000).map do |i|
    rand_time = earlist_time.since(rand(latest_time - earlist_time))
    rand_time_as_s = rand_time.to_formatted_s(:db)
    s = "('#{rand_time_as_s}', NULL, NULL, '#{SkipFaker::rand_char}', '#{rand_entry_type}', '#{rand_aim_type}', 0, '#{rand_time_as_s}', '#{rand_time_as_s}', 0, #{rand(100)}, NULL, 0, '#{rand_time_as_s}', '#{SkipFaker::rand_char}', 1, NULL, 0, 0, 'hiki')"
    #puts s
    s
  end.join(',')

con = ActiveRecord::Base.connection();
puts "start insert sql: #{Time.now.to_formatted_s(:db)}"
con.execute sql
puts "end insert sql: #{Time.now.to_formatted_s(:db)}"

