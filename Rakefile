require 'rubygems'

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake'
require 'rake/extensiontask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "taxamatch_rb"
    gem.summary = 'Implementation of Tony Rees Taxamatch algorithms'
    gem.description = 'This gem implements algorithm for fuzzy matching scientific names developed by Tony Rees'
    gem.email = "dmozzherin@eol.org"
    gem.homepage = "http://github.com/GlobalNamesArchitecture/taxamatch_rb"
    gem.authors = ["Dmitry Mozzherin"]
    gem.files = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec}/**/*"]
    gem.add_dependency('biodiversity','>= 0.5.13')
    gem.add_dependency('rake-compiler')
    gem.extensions = FileList['ext/**/extconf.rb','ext/**/*.c', 'ext/**/*.h']
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
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

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION.yml')
    config = YAML.load(File.read('VERSION.yml'))
    version = "#{config[:major]}.#{config[:minor]}.#{config[:patch]}"
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "taxamatch_rb #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Rake::ExtensionTask.new("damerau_levenshtein") do |extension|
    extension.lib_dir = "lib/taxamatch_rb"
end

task :build => [:clean, :compile]

Rake::Task[:spec].prerequisites << :build

