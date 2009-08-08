# Algorithms for Taxamatch::Authmatch are developed by Patrick Leary of uBio and EOL fame

module Taxamatch
  class Authmatch

    def self.authmatch(authors1, authors2, years1, years2)
      unique_authors1, unique_authors2 = remove_duplicate_authors(authors1, authors2)
      year_difference = compare_years(years1, years2)
      get_score(authors1, unique_authors1, authors2, unique_authors2, year_difference)
    end
  
    def self.get_score(authors1, unique_authors1, authors2, unique_authors2, year_diff)
      count_before = authors1.size + authors2.size
      count_after = unique_authors1.size + unique_authors2.size
      score = 0
      if count_after == 0
        if year_diff != nil
          if year_diff == 0
            score = 100
          elsif year_diff == 1
            score = 54  
          end
        else
          score = 94
        end
      elsif unique_authors1.size == 0 || unique_authors2.size == 0
        if year_diff != nil
          if year_diff == 0
            score = 91
          elsif year_diff == 1
            score = 51
          end
        else
          score = 90
        end
      else
        score = ((1 - count_after.to_f/count_before.to_f) * 100).round
        score = 0 unless year_diff == nil || (year_diff && year_diff == 0)  
      end
      score > 50 ? score : 0
    end
  
    def self.remove_duplicate_authors(authors1, authors2)
      unique_authors1 = authors1.dup
      unique_authors2 = authors2.dup
      authors1.each do |au1|
        authors2.each do |au2|
          au1_match = au2_match = false
          if au1 == au2
            au1_match = au2_match = true
          elsif au1 == au2[0...au1.size]          
            au1_match = true
          elsif au1[0...au2.size] == au2
            au2_match = true
          end
          if (au1.size >= 3 && au1_match) || (au2.size >= 3 && au2_match) || (au1_match && au2_match)
            unique_authors1.delete au1
            unique_authors2.delete au2
          elsif au1_match
            unique_authors1.delete au1
          elsif au2_match
            unique_authors2.delete au2
          else
            #TODO: masking a bug in damerau levenshtsin mod which appears comparing 1letter to a longer string
            if au1.size > 1 && au2.size > 1 && self.fuzzy_match_authors(au1, au2)
              unique_authors1.delete au1
              unique_authors2.delete au2
            end
          end
        end
      end
      [unique_authors1, unique_authors2]
    end
  
    def self.fuzzy_match_authors(author1, author2)
      au1_length = author1.size
      au2_length = author2.size
      dlm = Taxamatch::DamerauLevenshteinMod.new
      ed = dlm.distance(author1, author2,2,3) #get around a bug in C code, but it really has to be fixed
      (ed <= 3 && ([au1_length, au2_length].min > ed * 2) && (ed < 2 || author1[0] == author2[0]))
    end

    def self.compare_years(years1, years2)
      return 0 if years1 == [] && years2 == []
      return (years1[0].to_i - years2[0].to_i).abs if years1.size == 1 && years2.size == 1
      nil
    end
  end
end