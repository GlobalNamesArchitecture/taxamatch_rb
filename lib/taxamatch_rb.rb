$:.unshift(File.dirname(__FILE__)) unless
   $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
# $:.unshift('taxamatch_rb')
require 'taxamatch_rb/damerau_levenshtein_mod'
require 'taxamatch_rb/parser'
require 'taxamatch_rb/normalizer'
require 'taxamatch_rb/phonetizer'
require 'taxamatch_rb/authmatch'

class Taxamatch
  
  def initialize
    @parser = TaxamatchParser.new
    @dlm = DamerauLevenshteinMod.new
  end
   
   
  #takes two scientific names and returns true if names match and false if they don't
  def taxamatch(str1, str2) 
    parsed_data_1 = @parser.parse(str1)
    parsed_data_2 = @parser.parse(str2)
    taxamatch_parsed_data(parsed_data_1, parsed_data_2)[:match]
  end
  
  #takes two hashes of parsed scientific names, analyses them and returns back 
  #this function is useful when species strings are preparsed.
  def taxamatch_parsed_data(parsed_data_1, parsed_data_2)
    result = nil
    result =  match_uninomial(parsed_data_1, parsed_data_2) if parsed_data_1[:uninomial] && parsed_data_2[:uninomial] 
    result =  match_multinomial(parsed_data_1, parsed_data_2) if parsed_data_1[:genus] && parsed_data_2[:genus]
    if result && result[:match]
      result[:match] = match_authors(parsed_data_1, parsed_data_2) > 0 ? true : false 
    end
    return result
  end
  
  def match_uninomial(parsed_data_1, parsed_data_2)
    return false
  end

  def match_multinomial(parsed_data_1, parsed_data_2)
    gen_match = match_genera(parsed_data_1[:genus], parsed_data_2[:genus])
    sp_match = match_species(parsed_data_1[:species], parsed_data_2[:species])
    au_match = match_authors(parsed_data_1, parsed_data_2)
    total_length = parsed_data_1[:genus][:epitheton].size + parsed_data_2[:genus][:epitheton].size + parsed_data_1[:species][:epitheton].size + parsed_data_2[:species][:epitheton].size
    match = match_matches(gen_match, sp_match)
    match.merge({:score => (1- match[:edit_distance]/(total_length/2))})
  end
  
  def match_genera(genus1, genus2)
    genus1_length = genus1[:normalized].size
    genus2_length = genus2[:normalized].size
    match = false
    ed = @dlm.distance(genus1[:normalized], genus2[:normalized],2,3)
    return {:edit_distance => ed, :phonetic_match => true, :match => true} if genus1[:phonetized] == genus2[:phonetized] 
    
    match = true if ed <= 3 && ([genus1_length, genus2_length].min > ed * 2) && (ed < 2 || genus1[0] == genus2[0])
    {:edit_distance => ed, :match => match, :phonetic_match => false} 
  end

  def match_species(sp1, sp2)
    sp1_length = sp1[:normalized].size
    sp2_length = sp2[:normalized].size
    sp1[:phonetized] = Phonetizer.normalize_ending sp1[:phonetized]
    sp2[:phonetized] = Phonetizer.normalize_ending sp2[:phonetized]
    match = false
    ed = @dlm.distance(sp1[:normalized], sp2[:normalized], 4, 4)
    return {:edit_distance => ed, :phonetic_match => true, :match => true} if sp1[:phonetized] == sp2[:phonetized]
    
    match = true if ed <= 4 && ([sp1_length, sp2_length].min >= ed * 2) && (ed < 2 || sp1[:normalized][0] == sp2[:normalized][0]) && (ed < 4 || sp1[:normalized][0...3] == sp2[:normalized][0...3])
    {:edit_distance => ed, :match => match, :phonetic_match => false}
  end
  
  def match_authors(parsed_data_1, parsed_data_2)
    au1 = parsed_data_1[:all_authors]
    au2 = parsed_data_2[:all_authors]
    yr1 = parsed_data_1[:all_years]
    yr2 = parsed_data_2[:all_years]
    Authmatch.authmatch(au1, au2, yr1, yr2)
  end
  
  def match_matches(genus_match, species_match, infraspecies_matches = []) 
    match = species_match
    match[:edit_distance] += genus_match[:edit_distance]
    match[:match] = false if match[:edit_distance] > 4
    match[:match] &&= genus_match[:match]
    match[:phonetic_match] &&= genus_match[:phonetic_match]
    match
  end

end
