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
    Normalizer.normalize_word('L-3eœ|pt[ura$').should == 'L-3EOEPTURA'
  end
end

describe 'Taxamatch' do
  before(:all) do
    @tm = Taxamatch.new
  end
  
  it 'should compare genera' do
    #edit distance 1 always match
    g1 = make_taxamatch_hash 'Plantago'
    g2 = make_taxamatch_hash 'Plantagon'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>false, :edit_distance=>1, :match=>true}
    #edit_distance above threshold does not math
    g1 = make_taxamatch_hash 'Plantago'
    g2 = make_taxamatch_hash 'This shouldnt match'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>false, :match=>false, :edit_distance=>4}
    #phonetic_match matches
    g1 = make_taxamatch_hash 'Plantagi'
    g2 = make_taxamatch_hash 'Plantagy'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>true, :edit_distance=>1, :match=>true}
    #distance 1 in first letter also matches
    g1 = make_taxamatch_hash 'Xantheri'
    g2 = make_taxamatch_hash 'Pantheri'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>false, :edit_distance=>1, :match=>true}
    #phonetic match tramps everything
    g1 = make_taxamatch_hash 'Xantheriiiiiiiiiiiiiii'
    g2 = make_taxamatch_hash 'Zanthery'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>true, :edit_distance=>4, :match=>true}
    #same first letter and distance 2 should match
    g1 = make_taxamatch_hash 'Xantherii'
    g2 = make_taxamatch_hash 'Xantherrr'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>false, :match=>true, :edit_distance=>2}
    #First letter is the same and distance is 3 should match, no phonetic match
    g1 = make_taxamatch_hash 'Xantheriii'
    g2 = make_taxamatch_hash 'Xantherrrr'
    @tm.match_genera(g1, g2).should == {:phonetic_match=>false, :match=>true, :edit_distance=>3}
    #Should not match if one of words is shorter than 2x edit distance and distance is 2 or 3
    g1 = make_taxamatch_hash 'Xant'
    g2 = make_taxamatch_hash 'Xanthe'
    @tm.match_genera(g1, g2).should ==  {:phonetic_match=>false, :match=>false, :edit_distance=>2}
    #Should not match if edit distance > 3 and no phonetic match
    g1 = make_taxamatch_hash 'Xantheriiii'
    g2 = make_taxamatch_hash 'Xantherrrrr'
    @tm.match_genera(g1, g2).should ==  {:phonetic_match=>false, :match=>false, :edit_distance=>4}
  end

  it 'should compare species' do
    #Exact match
    s1 = make_taxamatch_hash 'major'
    s2 = make_taxamatch_hash 'major'
    @tm.match_species(s1, s2).should ==  {:phonetic_match=>true, :match=>true, :edit_distance=>0}
    #Phonetic match always works
    s1 = make_taxamatch_hash 'xanteriiiiiiii'
    s2 = make_taxamatch_hash 'zantereeeeeeee'
    @tm.match_species(s1, s2).should ==  {:phonetic_match=>true, :match=>true, :edit_distance=>5}
    #Phonetic match works with different endings
    s1 = make_taxamatch_hash 'majorum'
    s2 = make_taxamatch_hash 'majoris'
    @tm.match_species(s1, s2).should ==  {:phonetic_match=>true, :match=>true, :edit_distance=>2}
    #Distance 4 matches if first 3 chars are the same
    s1 = make_taxamatch_hash 'majorrrrr'
    s2 = make_taxamatch_hash 'majoraaaa'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>true, :edit_distance=>4}
    #Should not match if Distance 4 matches and first 3 chars are not the same
    s1 = make_taxamatch_hash 'majorrrrr'
    s2 = make_taxamatch_hash 'marorraaa'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>false, :edit_distance=>4}
    #Distance 2 or 3 matches if first 1 char is the same
    s1 = make_taxamatch_hash 'morrrr'
    s2 = make_taxamatch_hash 'moraaa'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>true, :edit_distance=>3}
    #Should not match if Distance 2 or 3 and first 1 char is not the same
    s1 = make_taxamatch_hash 'morrrr'
    s2 = make_taxamatch_hash 'torraa'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>false, :edit_distance=>3} 
    #Distance 1 will match anywhere
    s1 = make_taxamatch_hash 'major'
    s2 = make_taxamatch_hash 'rajor'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>true, :edit_distance=>1} 
    #Will not match if distance 3 and length is less then twice of the edit distance
    s1 = make_taxamatch_hash 'marrr'
    s2 = make_taxamatch_hash 'maaaa'
    @tm.match_species(s1, s2).should == {:phonetic_match=>false, :match=>false, :edit_distance=>3}
  end
  
  it 'should match mathes' do
    #No trobule case
    gmatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    smatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>true, :edit_distance=>2, :match=>true}
    #Will not match if either genus or sp. epithet dont match
    gmatch = {:match => false, :phonetic_match => false, :edit_distance => 1}
    smatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>false, :edit_distance=>2, :match=>false}
    gmatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    smatch = {:match => false, :phonetic_match => false, :edit_distance => 1}    
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>false, :edit_distance=>2, :match=>false}
    #Should not match if binomial edit distance > 4 NOTE: EVEN with full phonetic match
    gmatch = {:match => true, :phonetic_match => true, :edit_distance => 3}
    smatch = {:match => true, :phonetic_match => true, :edit_distance => 2}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>true, :edit_distance=>5, :match=>false}
    #Should not have phonetic match if one of the components does not match phonetically
    gmatch = {:match => true, :phonetic_match => false, :edit_distance => 1}
    smatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>false, :edit_distance=>2, :match=>true}
    gmatch = {:match => true, :phonetic_match => true, :edit_distance => 1}
    smatch = {:match => true, :phonetic_match => false, :edit_distance => 1}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>false, :edit_distance=>2, :match=>true}
    #edit distance should be equal the sum of of edit distances
    gmatch = {:match => true, :phonetic_match => true, :edit_distance => 2}
    smatch = {:match => true, :phonetic_match => true, :edit_distance => 2}
    @tm.match_matches(gmatch, smatch).should == {:phonetic_match=>true, :edit_distance=>4, :match=>true}
  end
end

def make_taxamatch_hash(string)
  normalized = Normalizer.normalize(string)
  {:epitheton => string, :normalized => normalized, :phonetized => Phonetizer.near_match(normalized)}
end
