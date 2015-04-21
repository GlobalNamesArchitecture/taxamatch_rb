require File.dirname(__FILE__) + "/../../lib/taxamatch_rb"

gem 'cucumber'
require 'cucumber'
require 'rspec'

Before do
  @tmp_root = File.dirname(__FILE__) + "/../../tmp"
  @home_path = File.expand_path(File.join(@tmp_root, "home"))
  FileUtils.rm_rf   @tmp_root
  FileUtils.mkdir_p @home_path
  ENV['HOME'] = @home_path
end
