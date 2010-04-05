if %w(production).include? ::Rails.env
  BoardEntry.handle_asynchronously :reflect_user_readings
  BoardEntryComment.handle_asynchronously :reflect_user_readings
end
