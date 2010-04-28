#Given /^"(.*)"ユーザのプロフィールページに"(.*)"回アクセスする$/ do |user, num|
#  num.to_i.times do
#    Given %!"#{user}ユーザのプロフィールページ"にアクセスする!
#  end
#end
#
#Given /^ランキングの"(.*)"位が"(.*)"のユーザであること$/ do |rank,uid|
#  Nokogiri::HTML(response.body).search("table.ranking_square tbody tr:nth(#{rank}) td.column_title a.ranking_author").text.should == uid
#end
#
Given /^"(.*)"回再読み込みする$/ do |num|
  num.to_i.times do |i|
    Given "再読み込みする"
  end
end

Given /^ランキングの"(.*)"位の数が"(.*)"であること$/ do |rank,num|
  Nokogiri::HTML(response.body).search("table.ranking_square tbody tr:nth(#{rank}) td.point").text.should == num.to_s
end

Given /^ランキングの"(.*)"位が"(.*)"というタイトルのブログであること$/ do |rank, title|
  Nokogiri::HTML(response.body).search("table.ranking_square tbody tr:nth(#{rank}) td.column_title a.ranking_title").text.should == title
end


#Given /^"(.*)"ランキングの"(.*)"分を表示する$/ do |category, date|
#  year, month = date.split("-")
#  visit ranking_data_path(:content_type => category, :year => year, :month => month)
#end

Given /^ランキングのバッチで"(.*)"の"(.*)"分を実行する$/ do |method, date|
  @@bmr = BatchMakeRanking.new
  @@bmr.send(method.to_sym, Time.local(*date.split("-")))
end

Given /^現在時刻の定義を一旦退避する$/ do
  class Time
    class << self
      alias origin_now now
    end
  end
end

Given /^現在時刻を(.*)とする$/ do |date|
  year, month, day = date.split('-')
  time_class_str = <<-RUBY
    class Time
      class << self
        alias origin_now now
        def now
          Time.local(#{year.to_i}, #{month.to_i}, #{day.to_i})
        end
      end
    end
  RUBY
  eval(time_class_str)
end

Given /^現在時刻を元に戻す$/ do
  class Time
    class << self
      alias now origin_now
    end
  end
end
