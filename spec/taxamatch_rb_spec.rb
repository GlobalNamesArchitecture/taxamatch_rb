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
    @parser.parse('Betula').should == {:all_authors=>[], :all_years=>[], :uninomial=>{:epitheton=>"Betula", :normalized=>"BETULA", :phonetized=>"BITILA", :authors=>[], :years=>[]}}
    @parser.parse('Ærenea Lacordaire, 1872').should == {:all_authors=>["Lacordaire"], :all_years=>["1872"], :uninomial=>{:epitheton=>"Aerenea", :normalized=>"AERENEA", :phonetized=>"ERINIA", :authors=>["Lacordaire"], :years=>["1872"]}}
    @parser.parse('Ærenea (Lacordaire, 1872) Muller 2007').should == {:all_authors=>["Lacordaire", "Muller"], :all_years=>["1872", "2007"], :uninomial=>{:epitheton=>"Aerenea", :normalized=>"AERENEA", :phonetized=>"ERINIA", :authors=>["Lacordaire", "Muller"], :years=>["1872", "2007"]}}
  end
  
  it 'should parse binomials' do
    @parser.parse('Leœptura laetifica Dow, 1913').should == {:all_authors=>["Dow"], :all_years=>["1913"], :genus=>{:epitheton=>"Leoeptura", :normalized=>"LEOEPTURA", :phonetized=>"LIPTIRA", :authors=>[], :years=>[]}, :species=>{:epitheton=>"laetifica", :normalized=>"LAETIFICA", :phonetized=>"LITIFICA", :authors=>["Dow"], :years=>["1913"]}}
  end
  
  it 'should parse trinomials' do 
    @parser.parse('Hydnellum scrobiculatum zonatum (Banker) D. Hall et D.E. Stuntz 1972').should == {:all_authors=>["Banker", "D. Hall", "D.E. Stuntz"], :all_years=>["1972"], :genus=>{:epitheton=>"Hydnellum", :normalized=>"HYDNELLUM", :phonetized=>"HIDNILIM", :authors=>[], :years=>[]}, :species=>{:epitheton=>"scrobiculatum", :normalized=>"SCROBICULATUM", :phonetized=>"SCRABICILATA", :authors=>[], :years=>[]}, :infraspecies=>[{:epitheton=>"zonatum", :normalized=>"ZONATUM", :phonetized=>"ZANATA", :authors=>["Banker", "D. Hall", "D.E. Stuntz"], :years=>["1972"]}]}
  end
end


describe 'Normalizer' do
  it 'should normalize  strings' do
    Normalizer.normalize('abcd').should == 'ABCD'
    Normalizer.normalize('Leœptura').should == 'LEOEPTURA'
    Normalizer.normalize('Ærenea').should == 'AERENEA'
    Normalizer.normalize('Fallén').should == 'FALLEN'
    Normalizer.normalize('abcd').should == 'ABCD'
    Normalizer.normalize('abcd').should == 'ABCD'    
  end
  
  it 'should normalize words' do
    Normalizer.normalize_word('Leœ|pt[ura$').should == 'LEOEPTURA'
  end
end