# ユーザのプロフィールを一括投入するスクリプト
#
# user1@test.com,hoge
# user2@test.com,fuga
# ...
# という形式のCSVを用意し、以下のように実行
#
# script/runner script/maintenance/add_user_profile_values.rb user_profile_master_id, path/to/csv
# * user_profile_master_idは数値、path/to/csvはcsvへの絶対パス
#
dry_run = true
user_profile_master_id = ARGV[0]
user_profile_master = UserProfileMaster.find(user_profile_master_id)
csv_path = ARGV[1]
ActiveRecord::Base.transaction do
  success_count = 0
  failed_count = 0
  begin
    loop_count = 1
    total_count = File.open(csv_path, 'r').read.split("\n").size
    FasterCSV.foreach(csv_path) do |row|
      puts row
      puts "run #{loop_count}/#{total_count}..."
      email = row[0]
      value = row[1]
      if user = User.find_by_email(email)
        if profile_value = user_profile_master.user_profile_values.find_by_user_id(user.id)
          profile_value.value = [profile_value.value, value].join(",")
          profile_value.save!
          success_count = success_count + 1
        else
          profile_value = user_profile_master.user_profile_values.build
          profile_value.user_id = user.id
          profile_value.value = value
          profile_value.save!
          success_count = success_count + 1
        end
      else
        failed_count = failed_count + 1
        puts "[Failed to save profile] the user was not found email: #{email}"
      end
      loop_count = loop_count + 1
    end
    puts "============================================================"
    puts "dry_run: #{dry_run}"
    puts "user_profile_master: id: #{user_profile_master.id} name: #{user_profile_master.name}"
    puts "csv_path: #{csv_path}"
    puts "success_count: #{success_count}"
    puts "failed_count: #{failed_count}"
    puts "============================================================"
    raise ActiveRecord::Rollback if dry_run
  end
end
