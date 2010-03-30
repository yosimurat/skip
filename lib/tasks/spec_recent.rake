require 'spec/rake/spectask'
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
