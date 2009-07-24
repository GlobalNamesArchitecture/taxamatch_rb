begin
  require 'spec'
rescue LoadError
  require 'rubygems' unless ENV['NO_RUBYGEMS']
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'taxamatch_rb'

def read_test_file
  f = open(File.expand_path(File.dirname(__FILE__)) + '/damerau_levenshtein_mod_test.txt')
  f.each do |line|
    str1, str2, max_dist, block_size, distance = line.split("|")
    if line.match(/^\s*#/) == nil && str1 && str2 && max_dist && block_size && distance
      distance = distance.split('#')[0].strip
      distance = (distance == 'null') ? nil : distance.to_i
      yield({:str1 => str1, :str2 => str2, :max_dist => max_dist.to_i, :block_size => block_size.to_i, :distance => distance})
    else
      yield({:comment => line})
    end
  end
end