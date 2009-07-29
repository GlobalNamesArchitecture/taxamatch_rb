begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'taxamatch_rb'

def read_test_file(file, fields_num)
  f = open(file)
  f.each do |line|
    fields = line.split("|")
    if line.match(/^\s*#/) == nil && fields.size == fields_num
      fields[-1] = fields[-1].split('#')[0].strip
      yield(fields)
    else
      yield(nil)
    end
  end
end

def make_taxamatch_hash(string)
  normalized = Normalizer.normalize(string)
  {:epitheton => string, :normalized => normalized, :phonetized => Phonetizer.near_match(normalized)}
end