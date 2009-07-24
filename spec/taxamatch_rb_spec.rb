require File.dirname(__FILE__) + '/spec_helper.rb'

describe 'DamerauLevensteinMod' do
  it 'should get tests' do
    read_test_file do |y|
      dl = DamerauLevenshteinMod.new
      unless y[:comment]
        # puts "%s, %s, %s" % [y[:str1], y[:str2], y[:distance]]
        dl.distance(y[:str1], y[:str2], y[:block_size], y[:max_dist]).should == y[:distance]
      end
    end
  end
end
