# EX)
# RAILS_ENV=production script/runner script/maintenance/delete_logs.rb

target_date = (Date.today - 1.month)

puts "[START] delete login_logs"
logs = LoginLog.created_at_lt(target_date)
puts "target record : #{logs.count}件"
logs.each do |log|
  log.delete
end

puts "[START] delete profile_access_logs"
logs = ProfileAccessLog.created_at_lt(target_date)
puts "target record : #{logs.count}件"
logs.each do |log|
  log.delete
end

puts "[START] delete full_text_search_logs"
logs = FullTextSearchLog.created_at_lt(target_date)
puts "target record : #{logs.count}件"
logs.each do |log|
  log.delete
end
