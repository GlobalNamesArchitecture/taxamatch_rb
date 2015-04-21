module Taxamatch

  class Base

    def initialize
      @parser = Taxamatch::Atomizer.new
      @dlm = DamerauLevenshtein
    end


    # takes two scientific names and returns true
    # if names match and false if they don't
    def taxamatch(str1, str2, return_boolean = true)
      preparsed_1 = @parser.parse(str1)
      preparsed_2 = @parser.parse(str2)
      match = taxamatch_preparsed(preparsed_1, preparsed_2) rescue nil
      return_boolean ? (!!match && match['match']) : match
    end

    # takes two hashes of parsed scientific names, analyses them and
    # returns back this function is useful when species strings are preparsed.
    def taxamatch_preparsed(preparsed_1, preparsed_2)
      result = nil
      if preparsed_1[:uninomial] && preparsed_2[:uninomial]
        result =  match_uninomial(preparsed_1, preparsed_2)
      end
      if preparsed_1[:genus] && preparsed_2[:genus]
        result =  match_multinomial(preparsed_1, preparsed_2)
      end
      if result && result['match']
        result['match'] = match_authors(preparsed_1, preparsed_2) == -1 ?
          false : true
      end
      return result
    end

    def match_uninomial(preparsed_1, preparsed_2)
      match_genera(preparsed_1[:uninomial], preparsed_2[:uninomial])
    end

    def match_multinomial(preparsed_1, preparsed_2)
      gen_match = match_genera(preparsed_1[:genus], preparsed_2[:genus])
      sp_match = match_species(preparsed_1[:species], preparsed_2[:species])
      total_length = preparsed_1[:genus][:string].size +
        preparsed_2[:genus][:string].size +
        preparsed_1[:species][:string].size +
        preparsed_2[:species][:string].size
      if preparsed_1[:infraspecies] && preparsed_2[:infraspecies]
        infrasp_match = match_species(preparsed_1[:infraspecies][0],
                                      preparsed_2[:infraspecies][0])
        total_length += preparsed_1[:infraspecies][0][:string].size +
          preparsed_2[:infraspecies][0][:string].size
        match_hash = match_matches(gen_match, sp_match, infrasp_match)
      elsif (preparsed_1[:infraspecies] && !preparsed_2[:infraspecies]) ||
        (!preparsed_1[:infraspecies] && preparsed_2[:infraspecies])
        match_hash = { 'match' => false,
          'edit_distance' => 5,
          'phonetic_match' => false }
        total_length += preparsed_1[:infraspecies] ?
          preparsed_1[:infraspecies][0][:string].size :
          preparsed_2[:infraspecies][0][:string].size
      else
        match_hash = match_matches(gen_match, sp_match)
      end
      match_hash.merge({ 'score' =>
                       (1 - match_hash['edit_distance']/(total_length/2)) })
      match_hash
    end

    def match_genera(genus1, genus2, opts = {})
      genus1_length = genus1[:normalized].size
      genus2_length = genus2[:normalized].size
      opts = { with_phonetic_match: true }.merge(opts)
      min_length = [genus1_length, genus2_length].min
      unless opts[:with_phonetic_match]
        genus1[:phonetized] = 'A'
        genus2[:phonetized] = 'B'
      end
      match = false
      ed = @dlm.distance(genus1[:normalized],
                         genus2[:normalized], 1, 3) #TODO put block = 2
      return { 'edit_distance' => ed,
        'phonetic_match' => false,
        'match' => false } if ed/min_length.to_f > 0.2
      return { 'edit_distance' => ed,
        'phonetic_match' => true,
        'match' => true } if genus1[:phonetized] == genus2[:phonetized]

      match = true if ed <= 3 && (min_length > ed * 2) &&
        (ed < 2 || genus1[0] == genus2[0])
      { 'edit_distance' => ed, 'match' => match, 'phonetic_match' => false }
    end

    def match_species(sp1, sp2, opts = {})
      sp1_length = sp1[:normalized].size
      sp2_length = sp2[:normalized].size
      opts = { with_phonetic_match: true }.merge(opts)
      min_length = [sp1_length, sp2_length].min
      unless opts[:with_phonetic_match]
        sp1[:phonetized] = 'A'
        sp2[:phonetized] = 'B'
      end
      sp1[:phonetized] = Taxamatch::Phonetizer.normalize_ending sp1[:phonetized]
      sp2[:phonetized] = Taxamatch::Phonetizer.normalize_ending sp2[:phonetized]
      match = false
      ed = @dlm.distance(sp1[:normalized],
                         sp2[:normalized], 1, 4) #TODO put block 4
      return { 'edit_distance' => ed,
        'phonetic_match' => false,
        'match' => false } if ed/min_length.to_f > 0.3334
      return {'edit_distance' => ed,
        'phonetic_match' => true,
        'match' => true} if sp1[:phonetized] == sp2[:phonetized]

      match = true if ed <= 4 &&
        (min_length >= ed * 2) &&
        (ed < 2 || sp1[:normalized][0] == sp2[:normalized][0]) &&
        (ed < 4 || sp1[:normalized][0...3] == sp2[:normalized][0...3])
      { 'edit_distance' => ed, 'match' => match, 'phonetic_match' => false }
    end

    def match_authors(preparsed_1, preparsed_2)
      p1 = { normalized_authors: [], years: [] }
      p2 = { normalized_authors: [], years: [] }
      if preparsed_1[:infraspecies] || preparsed_2[:infraspecies]
        p1 = preparsed_1[:infraspecies].last if preparsed_1[:infraspecies]
        p2 = preparsed_2[:infraspecies].last if preparsed_2[:infraspecies]
      elsif preparsed_1[:species] || preparsed_2[:species]
        p1 = preparsed_1[:species] if preparsed_1[:species]
        p2 = preparsed_2[:species] if preparsed_2[:species]
      elsif preparsed_1[:uninomial] && preparsed_2[:uninomial]
        p1 = preparsed_1[:uninomial]
        p2 = preparsed_2[:uninomial]
      end
      au1 = p1[:normalized_authors]
      au2 = p2[:normalized_authors]
      yr1 = p1[:years]
      yr2 = p2[:years]
      return 0 if au1.empty? || au2.empty?
      score = Taxamatch::Authmatch.authmatch(au1, au2, yr1, yr2)
      score == 0 ? -1 : 1
    end

    def match_matches(genus_match, species_match, infraspecies_match = nil)
      match = species_match
      if infraspecies_match
        match['edit_distance'] += infraspecies_match['edit_distance']
        match['match'] &&= infraspecies_match['match']
        match['phonetic_match'] &&= infraspecies_match['phonetic_match']
      end
      match['edit_distance'] += genus_match['edit_distance']
      if match['edit_distance'] > (infraspecies_match ? 6 : 4)
        match['match'] = false
      end
      match['match'] &&= genus_match['match']
      match['phonetic_match'] &&= genus_match['phonetic_match']
      match
    end

  end
end

