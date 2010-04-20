gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9
rspec_gem_dir = nil
Dir["#{RAILS_ROOT}/vendor/gems/*"].each do |subdir|
  rspec_gem_dir = subdir if subdir.gsub("#{RAILS_ROOT}/vendor/gems/","") =~ /^(\w+-)?rspec-(\d+)/ && File.exist?("#{subdir}/lib/spec/rake/spectask.rb")
end
rspec_plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../../vendor/plugins/rspec')

if rspec_gem_dir && (test ?d, rspec_plugin_dir)
  raise "\n#{'*'*50}\nYou have rspec installed in both vendor/gems and vendor/plugins\nPlease pick one and dispose of the other.\n#{'*'*50}\n\n"
end

if rspec_gem_dir
  $LOAD_PATH.unshift("#{rspec_gem_dir}/lib")
elsif File.exist?(rspec_plugin_dir)
  $LOAD_PATH.unshift("#{rspec_plugin_dir}/lib")
end

# Don't load rspec if running "rake gems:*"
unless ARGV.any? {|a| a =~ /^gems/}

begin
  require 'spec/rake/spectask'
rescue MissingSourceFile
  module Spec
    module Rake
      class SpecTask
        def initialize(name)
          task name do
            # if rspec-rails is a configured gem, this will output helpful material and exit ...
            require File.expand_path(File.join(File.dirname(__FILE__),"..","..","config","environment"))

            # ... otherwise, do this:
            raise <<-MSG

#{"*" * 80}
*  You are trying to run an rspec rake task defined in
*  #{__FILE__},
*  but rspec can not be found in vendor/gems, vendor/plugins or system gems.
#{"*" * 80}
MSG
          end
        end
      end
    end
  end
end

# Grab recently touched specs
def recent_specs(touched_since)
  recent_specs = FileList['app/**/*.rb'].map do |path|
    if File.mtime(path) > touched_since
      spec = File.join('spec', File.dirname(path).split("/")[1..-1].join('/'),
        "#{File.basename(path, '.rb')}_spec.rb")
      spec if File.exists?(spec)
    end
  end.compact
  recent_specs += FileList['spec/**/*_spec.rb'].select do |path|
    File.mtime(path) > touched_since
  end.uniq
end

desc 'Run recent specs'
Spec::Rake::SpecTask.new("spec:recent") do |t|
  t.spec_opts = ["--format","specdoc","--color"]
  t.spec_files = recent_specs(Time.now - 600) # 10 min.
end

def last_spec(touched_since)
  recent_specs(touched_since).sort_by { |path| File.mtime(path) }.first
end

desc 'Run last specs'
Spec::Rake::SpecTask.new("spec:last") do |t|
  t.spec_opts = ["--format","specdoc","--color"]
  t.spec_files = last_spec(Time.now - 600) # 10 min.
end

end
