require 'rubygems'

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = 'taxamatch_rb'
    gem.summary = 'Implementation of Tony Rees Taxamatch algorithms'
    gem.description = 'This gem implements algorithm ' +
      'for fuzzy matching scientific names developed by Tony Rees'
    gem.email = 'dmozzherin@gmail.com'
    gem.homepage = 'http://github.com/GlobalNamesArchitecture/taxamatch_rb'
    gem.authors = ['Dmitry Mozzherin']
    gem.files = FileList['[A-Z]*',
      '*.gemspec', '{bin,generators,lib,spec}/**/*']
    gem.files -= FileList['lib/**/*.bundle', 'lib/**/*.dll', 'lib/**/*.so']
    gem.files += FileList['ext/**/*.c']
    gem.extensions = FileList['ext/**/extconf.rb']
  end

rescue LoadError
  puts 'Jeweler (or a dependency) not available.' +
  ' Install it with: sudo gem install jeweler'
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec
