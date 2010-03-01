class SkipFormat < RequestLogAnalyzer::FileFormat::Rails
  REQUEST_CATEGORIZER_PER_CURRENT_USER = Proc.new do |request|
    "#{request[:uid]} #{request[:controller]}##{request[:action]}.#{request[:format]} [#{request[:method]}]"
  end

  REQUEST_CATEGORIZER_PER_CURRENT_TARGET_USER = Proc.new do |request|
    "#{request[:url].split('/').last} #{request[:controller]}##{request[:action]}.#{request[:format]} [#{request[:method]}]"
  end

  line_definition :search_requested_per_user do |line|
    line.regexp = /\[Log for inspection\]: \{\"user_id\" => \"(\d)\", \"uid\" => \"(.+)\"}/
    line.captures << { :name => :user_id, :type => :string }
    line.captures << { :name => :uid, :type => :string }
  end

  report(:append) do |analyze|
    analyze.frequency :category => REQUEST_CATEGORIZER_PER_CURRENT_USER, :title => "Search requested per user", :line_type => :search_requested_per_user, :if => lambda { |request| request[:controller] == 'SearchController' && request[:action] == 'full_text_search' }
    analyze.frequency :category => REQUEST_CATEGORIZER_PER_CURRENT_TARGET_USER, :title => "User profile requested", :line_type => :search_requested_per_user, :if => lambda { |request| request[:controller] == 'UserController' && request[:action] == 'show' }
  end
end
