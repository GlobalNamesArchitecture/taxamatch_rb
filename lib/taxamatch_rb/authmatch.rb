class Authmatch

  def self.authmatch(authors1, authors2, years1, years2)
    return true
    unique_authors1, unique_authors2 = remove_duplicate_authors(authors1, authors2)
    year_difference = compare_years(years1, years2)
  

    #return get_score_author_comparison(authors1, unique_authors1, authors2, unique_authors2, year_difference, 50, true);
  end
  
  def self.remove_duplicate_authors(author1, authors2)
    au1_match = au2_match = false
    au1_match.each do |au1|
      match1 = false
      au1_match.each do |au2|
        match2 = false
        if au1 == au2
          match1 = match2 = true
        elsif au1.size < au2.size
          match1 = true if au1 == au2[0..au1.size]
        elseif 
        end
      end
    end
  end

  def self.compare_years(years1, years2)
    return 0 if years1 == [] && years2 == []
    return (years1[0] - years2[0]).abs if years1.size == 1 && years2.size == 1
    nil
  end
end

=begin
		foreach($author_words1 as $key1 => $author1)
		{
			$author1_matches = false;
			$author1 = Normalize::normalize_author_string($author1);
			foreach($author_words2 as $key2 => $author2)
				{
				$author2_matches = false;
				$author2 = Normalize::normalize_author_string($author2);

				if($author1 == $author2)
				{
					$author1_matches = true;
					$author2_matches = true;
				}elseif(preg_match("/^".preg_quote($author1, "/")."/i", $author2))
				{
					$author1_matches = true;
				}elseif(preg_match("/^".preg_quote($author2, "/")."/i", $author1))
				{
					$author2_matches = true;
				}

				// equal or one is contained in the other, so consider it a match for both terms
				if((strlen($author1)>=3 && $author1_matches) || (strlen($author2)>=3 && $author2_matches) || $author1 == $author2)
				{
					unset($unique_authors1[$key1]);
					unset($unique_authors2[$key2]);
				}elseif($author1_matches)
				{
					// author1 was abbreviation of author2
					unset($unique_authors1[$key1]);
				}elseif($author2_matches)
				{
				// author1 was abbreviation of author2
					unset($unique_authors2[$key2]);
				}else
				{
					// no match or abbreviation so try a fuzzy match
					$max_length = max(strlen($author1), strlen($author2));
					$lev = levenshtein($author1, $author2);
					if(($lev/$max_length) <= .167)
					{
						unset($unique_authors1[$key1]);
						unset($unique_authors2[$key2]);
					}
			}
		}
		reset($author_words2);
	}
	
  
=end