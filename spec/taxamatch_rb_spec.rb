# encoding: UTF-8
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

describe 'Parser' do
  before(:all) do
    @parser = Parser.new
  end
  
  it 'should parse uninomials' do
    @parser.parse('Betula').should == {:uninomial=>{:epitheton=>"BETULA", :authors=>[], :years=>[]}}
    @parser.parse('Ærenea Lacordaire, 1872').should == {:uninomial=>{:epitheton=>"AERENEA", :authors=>["Lacordaire"], :years=>["1872"]}}
    @parser.parse('Ærenea (Lacordaire, 1872) Muller 2007').should == {:uninomial=>{:epitheton=>"AERENEA", :authors=>["Lacordaire", "Muller"], :years=>["1872", "2007"]}}
  end
  
  it 'should parse binomials' do
    @parser.parse('Leœptura laetifica Dow, 1913').should == {:genus=>{:epitheton=>"LEOEPTURA", :authors=>[], :years=>[]}, :species=>{:epitheton=>"LAETIFICA", :authors=>["Dow"], :years=>["1913"]}}
  end
  
  it 'should parse trinomials' do 
    @parser.parse('Hydnellum scrobiculatum zonatum (Banker) D. Hall et D.E. Stuntz 1972').should == {:genus=>{:epitheton=>"HYDNELLUM", :authors=>[], :years=>[]}, :species=>{:epitheton=>"SCROBICULATUM", :authors=>[], :years=>[]}, :infraspecies=>[{:epitheton=>"ZONATUM", :authors=>["Banker", "D. Hall", "D.E. Stuntz"], :years=>["1972"]}]}
  end
end