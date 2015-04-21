require "bundler/gem_tasks"
require "rake"
require "rspec/core"
require "rspec/core/rake_task"
require "cucumber"
require "cucumber/rake/task"

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

# Cucumber::Rake::Task.new(:features)
Cucumber::Rake::Task.new(:features) do |t|
    t.cucumber_opts = "features --format pretty"
end

task default: [:features, :spec]

