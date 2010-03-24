require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "taxamatch_rb"
    gem.summary = 'Implementation of Tony Rees Taxamatch algorithms'
    gem.description = 'This gem implements algorithsm for fuzzy matching scientific names developed by Tony Rees'
    gem.email = "dmozzherin@eol.org"
    gem.homepage = "http://github.com/dimus/taxamatch_rb"
    gem.authors = ["Dmitry Mozzherin"]
    gem.files = FileList["[A-Z]*.*", "{bin,generators,lib,test,spec}/**/*"]
    gem.add_dependency('RubyInline')
    gem.add_dependency('biodiversity','>= 0.5.13')
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
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

