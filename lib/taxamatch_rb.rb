$:.unshift(File.dirname(__FILE__)) unless
   $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
# $:.unshift('taxamatch_rb')
require 'taxamatch_rb/damerau_levenshtein_mod'
require 'taxamatch_rb/parser'
require 'taxamatch_rb/normalizer'
require 'taxamatch_rb/phonetizer'

class Taxamatch
  
  def initialize
    @parser = Parser.new
    @dlm = DamerauLevenshteinMod.new
  end
   
   
  #takes two scientific names and returns true if names match and false if they don't
  def taxamatch(str1, str2) 
    parsed_data_1 = @parser.parse(str1)
    parsed_data_2 = @parser.parse(str2)
    
    taxamatch_parsed_data(parsed_data_1, parsed_data_2)[:matched]
  end
  
  #takes two hashes of parsed scientific names, analyses them and returns back 
  #this function is useful when species strings are preparsed.
  def taxamatch_parsed_data(parsed_data_1, parsed_data_2)
    return match_uninomial(parsed_data_1, parsed_data_2) if parsed_data_1[:unicode] && parsed_data_2[:unicode] 
    return match_multinomial(parsed_data_1, parsed_data_2) if parsed_data_1[:genus] && parsed_data_2[:genus]
    return nil
  end
  
  def match_uninomial(parsed_data_1, parsed_data_2)
    return nil
  end

  def match_multinomial(parsed_data_1, parsed_data_2)
    gen_match = match_genera(parsed_data_1[:genus], parsed_data_2[:genus])
    sp_match = match_species(parsed_data_1[:species], parsed_data_2[:species])
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
  
  def match_matches(genus_match, species_match, infraspecies_matches = []) 
    match = species_match
    match[:edit_distance] += genus_match[:edit_distance]
    match[:match] = false if match[:edit_distance] > 4
    match[:match] &&= genus_match[:match]
    match[:phonetic_match] &&= genus_match[:phonetic_match]
    match
  end

end


# 
#     public function name_strings_match($name_string1, $name_string2) {
#       $info_1 = new Splitter(null,$name_string1);
#       $info_2 = new Splitter(null,$name_string2);
#       return $this->name_objects_match($info_1, $info_2);
#     }
#     
#     public function name_objects_match($name_object_1, $name_object_2) {
#       $genus_match = $this->match_genera($name_object_1->genus, $name_object_2->genus);
#       $epithets_match = $this->match_species_epithets($name_object_1->species, $name_object_2->species);
#       $total_length = strlen($name_object_1->genus) + strlen($name_object_1->species) + strlen($name_object_2->genus) + strlen($name_object_2->species);
#       $match = $this->match_binomials($genus_match, $epithets_match);
#       return $this->match_response_to_float($match, $total_length);
#     }
#     
#     public function match_response_to_float($match_response, $total_length_of_strings) {
#       if(!$match_response['match']) return 0.0;
#       
#       return (1 - ($match_response['edit_distance'] / ($total_length_of_strings/2)));
#     }
#     
#     public function match_genera($genus1, $genus2) {
#       $match = $phonetic_match = false;
#       $nm = new NearMatch();
#       $genus1_phonetic = $nm->near_match($genus1);
#       $genus2_phonetic = $nm->near_match($genus2);
#       $genus1_length = strlen($genus1);
# 
#       $temp_genus_ED = $this->mdld($genus2, $genus1, 2);
#       // add the genus post-filter
#       // min. 51% "good" chars
#       // first char must match for ED 2+
#       if( ($temp_genus_ED <= 3 && ( min( strlen( $genus2 ), $genus1_length ) > ( $temp_genus_ED * 2 ))
#             && ( $temp_genus_ED < 2 || ( substr($genus2,0,1) == substr($genus1,0,1) ) ) )    
#           || ($genus1_phonetic == $genus2_phonetic) ) {
#         $match = true;
#         // accept as exact or near match; append to genus results table
#         $this->debug['process'][] = "6a (near_match_genus:$genus2_phonetic) (this_near_match_genus:$genus1_phonetic)";
# 
#         if($genus1_phonetic == $genus2_phonetic) $phonetic_match = true;
#       }
#       return array(
#         'match' => $match, 
#         'phonetic_match' => $phonetic_match, 
#         'edit_distance' => $temp_genus_ED);
#     }
#     
#     public function match_species_epithets($species_epithet1, $species_epithet2) {
#       $match = false;
#       $phonetic_match = false;
#       $epithet1_length = strlen($species_epithet1);
#       $epithet2_length = strlen($species_epithet2);
#       
#       $nm = new NearMatch();
#       $epithet1_phonetic = $nm->near_match($species_epithet1);
#       $epithet2_phonetic = $nm->near_match($species_epithet2);
#       $temp_species_ED = $this->mdld($species_epithet2, $species_epithet1, 4);
#       // add the species post-filter
#       // min. 50% "good" chars
#       // first char must match for ED2+
#       // first 3 chars must match for ED4
#       if ($epithet2_phonetic == $epithet1_phonetic) $match = true;
#       elseif( ($temp_species_ED <= 4 && min($epithet2_length, $epithet1_length) >= ($temp_species_ED*2)
#         && ($temp_species_ED < 2 || strpos($species_epithet2 , substr($species_epithet1,0,1)) !== false)
#         && ($temp_species_ED < 4 || strpos($species_epithet2 , substr($species_epithet1,0,3)) !== false))) $match = true;
#       
#       // if phonetic match, set relevant flag
#       if ($epithet2_phonetic == $epithet1_phonetic) $phonetic_match = true;
#       
#       return array('match' => $match, 'phonetic_match' => $phonetic_match, 'edit_distance' => $temp_species_ED);
#     }
#     
#     
#     public function match_binomials($genus_match, $species_epithets_match) {
#       $binomial_match = $species_epithets_match;
#       $binomial_match['edit_distance'] = $genus_match["edit_distance"] + $species_epithets_match["edit_distance"];
#       
#       if(!$genus_match['match']) $binomial_match['match'] = false;
#       if($binomial_match["edit_distance"] > 4)  $binomial_match['match'] = false;
#       if(!$genus_match['phonetic_match']) $binomial_match['phonetic_match'] = false;
#       
#       
#       return $binomial_match;
#     }
#     
#     // public function match_species($genus1, $species_epithet1, $genus2, $species_epithet2, $genus_edit_distance) {
#     //  $match = false;
#     //  $phonetic_match = false;
#     //  $epithet1_length = strlen($species_epithet1);
#     //  $epithet2_length = strlen($species_epithet2);
#     //  
#     //  $nm = new NearMatch();
#     //  $genus1_phonetic = $nm->near_match(genus1);
#     //  $genus2_phonetic = $nm->near_match(genus2);     
#     //  $epithet1_phonetic = $nm->near_match($species_epithet1);
#     //  $epithet2_phonetic = $nm->near_match($species_epithet2);
#     //  $temp_species_ED = $this->mdld($species2, $species1, 4);
#     //  // add the species post-filter
#     //  // min. 50% "good" chars
#     //  // first char must match for ED2+
#     //  // first 3 chars must match for ED4
#     //  if ( ($epithet2_phonetic == $epithet1_phonetic) 
#     //    || ( ($genus_edit_distance + $temp_species_ED <= 4)
#     //    && ($temp_species_ED <= 4 && min(strlen($epithet2_length),$epithet1_length) >= ($temp_species_ED*2)
#     //    && ($temp_species_ED < 2 || strpos($species_epithet2 , substr($species_epithet1,1,1)) !== false)
#     //    && ($temp_species_ED < 4 || strpos($species_epithet2 , substr($species_epithet1,1,3)) !== false) 
#     //    && ($genus_edit_distance + $temp_species_ED <= 4) ))) {
#     //    $match = true;
#     //    // accept as exact or near match, append to species results table
#     //    // if phonetic match, set relevant flag
#     //    if ( ($genus2_phonetic == $genus1_phonetic) && ($epithet2_phonetic == $epithet1_phonetic) ) $phonetic_match = true;
#     //  }
#     //  return array('match' => $match, 'phonetic_match' => $phonetic_match, 'edit_distance' => $temp_species_ED);
#     // }
# 
#     /**
#      * Function : process
#      * Purpose: Perform exact and fuzzy matching on a species name, or single genus name
#      * Input: - genus, genus+species, or genus+species+authority (in this version), as "searchtxt"
#      *        - "search_mode" to control search mode: currently normal (default) / rapid / no_shaping
#      *        - "debug" - print internal parameters used if not null
#      * Outputs: list of genera and species that match (or near match) input terms, with associated
#      *   ancillary info as desired
#      * Remarks:
#      *   (1) This demo version is configured to access base data in three tables:
#      *          - genlist_test1 (genus info); primary key (PK) is genus_id
#      *          - splist_test1 (species info); PK is species_id, has genus_id as foreign key (FK)
#      *              (= link to relevant row in genus table)
#      *          - auth_abbrev_test1 (authority abbreviations - required by subsidiary function
#      *            "normalize_auth". Refer README file for relevant minimum table definitions.
#      *       If authority comparisons are not required, calls to "normalize_auth" can be disabled and
#      *         relevant function commented out, removing need for third table.
#      *       (In a production system, table and column names can be varied as desired so long as
#      *         code is altered at relevant points, also could be re-configured to hold all genus+species info together in a single table with minor re-write).
#      *   (2) Writes to and reads back from pre-defined global temporary tables
#      *      "genus_id_matches" and "species_id_matches", new instances of these are automatically
#      *      created for each session (i.e., do not need clearing at procedure end). Refer
#      *      README file for relevant table definitions.
#      *   (3) When result shaping is on in this version, a relevant message displayed as required
#      *      for developer feedback, if more distant results are being masked (in producton version,
#      *       possibly would not do this)
#      *   (4) Requires the following subsidiary functions (supplied elsewhere in this package):
#      *         - normalize
#      *         - normalize_auth
#      *         - reduce_spaces
#      *         - ngram
#      *         - compare_auth
#      *         - near_match
#      *         - mdld
#      *   (5) Accepts "+" as input separator in place of space (e.g. "Homo+sapiens"), e.g. for calling
#      *         via a HTTP GET request as needed.
#      * @param string $searchtxt : genus, genus+species, or genus+species+authority
#      * @param string $search_mode : normal (default) / rapid / no_shaping
#      * @param boolean $cache
#      * @return boolean
#      */
#     public function process($searchtxt, $search_mode='normal', $cache = false) {
# 
#       $this->input = $searchtxt;
# 
#       $this->debug['process'][] = "1 (searchtxt:$searchtxt) (search_mode:$search_mode)";
#       $this->searchtxt = $searchtxt;
#       $this->search_mode=$search_mode;
# 
#       // accept "+" as separator if supplied, tranform to space
#       if ( strpos($this->searchtxt,'+') !== false ) {
#         $text_str = str_replace('+',' ',$this->searchtxt);
#       } else {
#         $text_str = $this->searchtxt;
#       }
# 
#       $this->debug['process'][] = "1a (text_str:$text_str)";
#       
#       if ( is_null($text_str) || $text_str == '' ) {
#         $this->debug['process'][] = "2 Return(false)";
#         return false;
#       }
# 
#       // Clearing the temporary tables
#       $this->db->clearTempTables();
# 
#       // includes stripping of presumed non-relevant content including subgenera, comments, cf's, aff's, etc... to 
# 
#       // Normalizing the search text
#       $n = new Normalize($this->db);
# 
#       $this->debug['process'][] = "3 (text_str:$text_str)";
# 
#       if(!$this->chop_overload) {
#         // leave presumed genus + species + authority (in this instance), with  genus and species in uppercase
#         $splitter = new Splitter($n,$text_str);
#         
#         $this->this_search_genus = $this_search_genus = $splitter->get('genus');
#         $this->this_search_species = $this_search_species = $splitter->get('species');
#         $this->this_authority = $this_authority = $splitter->get('author');     
#       }
# 
#       // cache_flag switch detemines if caching is allowed for the source
#       if($this->cache_flag == true) {
# 
#         if ( $this_search_genus != '' && $this_search_species != '' && $this_authority != '' ) {
#           $cache_key = $this_search_genus . '-' . $this_search_species . '-' . $this_authority . '_' . $search_mode;
#           $cache_path = $this->cache_path . $this->db->source . "/authority/";
#         } else if ( $this_search_genus != '' && $this_search_species != '' ) {
#           $cache_key = $this_search_genus . '-' . $this_search_species . '_' . $search_mode;
#           $cache_path = $this->cache_path . $this->db->source . "/species/";
#         } else if ( $this_search_genus != '' ) {
#           $cache_key = $this_search_genus . '_' . $search_mode;
#           $cache_path = $this->cache_path . $this->db->source . "/genus/";
#         }
#         
#         $this->mkdir_recursive($cache_path);
#         $this->_cache = new Cache( $cache_path );
#         $this->_cache->setKey($cache_key);
# 
#       }
# 
#       $cache_loop_flag = false;
#       if($cache == true && $this->cache_flag == true) {
#         if($this->_cache->cache_exists()) $cache_loop_flag = true;
#       }
# 
#       if(!$cache_loop_flag) {
# 
#         $this->debug['process'][] = "3a (this_search_genus:$this_search_genus) (this_search_species:$this_search_species) (this_authority:$this_authority)";
#   
#         $nm = new NearMatch();
#         $this_near_match_genus = $nm->near_match($this_search_genus);
#   
#         $this->debug['process'][] = "3b (this_near_match_genus:$this_near_match_genus)";
# //TODO refactor inside of a method
#         $this_genus_start = substr($this_search_genus,0,3);
#         $this_genus_end = substr($this_search_genus,-3);
#         $this_genus_length = strlen($this_search_genus);
# //TODO_END
#         $this->debug['process'][] = "3c (this_search_genus,$this_search_genus) (this_genus_start:$this_genus_start) (this_genus_end:$this_genus_end) (this_genus_length:$this_genus_length)";
#   
#         if ($this_search_species != '') {
#           $this_near_match_species = $nm->near_match($this_search_species, 'epithet_only');
#           $this_species_length = strlen($this_search_species);
#           $this->debug['process'][] = "4 (this_search_species:$this_search_species) (this_near_match_species:$this_near_match_species) (this_species_length:$this_species_length)";
#         }
#   
#   
#         // now look for exact or near matches on genus first select candidate genera for edit distance (MDLD) test
#   
#         // for drec in genus_cur loop -- includes the genus pre-filter (main portion)
#         $genus_res = $this->db->genus_cur($this->search_mode, $this_near_match_genus, $this_near_match_species, $this_genus_length,$this_genus_start,$this_genus_end);
#   
#         $this->debug['process'][] = "5 (genus_res:$genus_res)";
#   
#         if(count($genus_res)) {
#           foreach($genus_res as $drec) {
#           // test candidate genera for edit distance, keep if satisfies post-test criteria
#           $this->genera_tested++;
#           // do the genus edit distance test
#           
#           $genus_match = $this->match_genera($this_search_genus, $drec->search_genus_name);
#           if ($genus_match['match']) {
#             $phonetic_flag = $genus_match['phonetic_match'] ? 'Y' : null;
#             $this->db->saveGenusMatches($drec->genus_id, $drec->genus, $genus_match['edit_distance'], $phonetic_flag);
#   
#             if ( ($this_search_species != null) && ($this_search_species != '') ) {
#               $species_res = $this->db->species_cur($drec->genus_id, $this_species_length );
#   
#               if(count($species_res)) {
#                 foreach($species_res as $drec1) {
#                   $this->species_tested++;
#                   
#                   // do the species edit distance test
#                   $species_epithets_match = $this->match_species_epithets($this_search_species, $drec1->search_species_name);
#                   $binomials_match = $this->match_binomials($genus_match, $species_epithets_match);
#                   if ($binomials_match['match']) {
#                     
#                     $bionial_phonetic_flag = $binomials_match['phonetic_match'] ? 'Y' : null;
#                     $this->db->saveSpeciesMatches($drec1->species_id, $drec1->genus_species, $genus_match['edit_distance'], $temp_species_ED, $binomials_match['edit_distance'], $bionial_phonetic_flag);
#                   } // 
#                 } // End foreach species_res
#               } // End If elements exist for species_res
#             } // End Search Species Exist
#           }
#         }
#       }
#     } // End Cache Loop Flag
#     return true;
#   }
# 
#     /**
#      * generateResponse
#      * Result generation section (including ranking, result shaping,
#      * and authority comparison) - for demo purposes only
#      * NB, in a production system this would be replaced by something
#      * more appropriate, e.g. write to a file or database table,
#      * generate a HTML page for web display,
#      * generate XML response, etc. etc.
#      * @param boolean $cache
#      * @return boolean
#      */
#     public function generateResponse($cache) {
# 
#       $cache_loop_flag = false;
#       if($cache == true && $this->cache_flag == true) {
#         if($this->_cache->cache_exists()) $cache_loop_flag = true;
#       }
#   
#   //    if($cache == true && $this->_cache->cache_exists() && $this->cache_flag == true) {
#       if($cache_loop_flag) {
#       
#         $this->data = $this->_cache->fetch();
#         $data_array = json_decode($this->data,true);
#         $data_array['cache'] = $cache;
#         $this->data = json_encode($data_array);
#         
#       } else {
#       
#         // genus exact, phonetic, and other near matches
#         $this->output['input'] = $this->searchtxt;
#         $this->debug['generateResponse'][] = "1 (input:" . $this->searchtxt . ")";
#     
#         // Genus Exact
#         $this->debug['generateResponse'][] = "1a (getGenusAuthority:exact)";
#         $this->getGenusAuthority(0,'exact');
#         // Genus Phonetic
#         $this->debug['generateResponse'][] = "1b (getGenusAuthority:phonetic)";
#         $this->getGenusAuthority('P','phonetic');
#         // Genus near matches
#         $this->debug['generateResponse'][] = "1c (getGenusAuthority:near_1)";
#         $this->getGenusAuthority(1,'near_1');
#         $this->debug['generateResponse'][] = "1d (getGenusAuthority:near_2)";
#         $this->getGenusAuthority(2,'near_2');
#   
#         if(!is_array($this->output['genus']) && $this->this_search_genus != '') {$this->output['genus'] = array();}
#     
#         if ( !is_null($this->this_search_species) ) {
#           // species exact, phonetic, and other near matches
#     
#           $this->debug['generateResponse'][] = "2a (getSpeciesAuthority:exact) ($this->this_authority)";
#           $this->getSpeciesAuthority( 0, 'exact', $this->this_authority );
#           $this->debug['generateResponse'][] = "2b (getSpeciesAuthority:phonetic) ($this->this_authority)";
#           $this->getSpeciesAuthority( 'P', 'phonetic', $this->this_authority );
#           $this->debug['generateResponse'][] = "2c (getSpeciesAuthority:near_1) ($this->this_authority)";
#           $this->getSpeciesAuthority( 1, 'near_1', $this->this_authority );
#           $this->debug['generateResponse'][] = "2d (getSpeciesAuthority:near_2) ($this->this_authority)";
#           $this->getSpeciesAuthority( 2, 'near_2', $this->this_authority );
#                   
#           // -- Here is the result shaping section (only show ED 3 if no ED 1,2 or phonetic matches, only
#           // --   show ED 4 if no ED 1,2,3 or phonetic matches). By default shaping is on, unless disabled
#           // --   via the input parameter "search_mode" set to 'no_shaping'.
#           // --   In this demo we supplement any actual shaping with a message to show that it has been invoked,
#           // --   to show the system operates correctly.
#           if ($this->species_found == 'Y') {
#             $temp_species_count = $this->db->countSpeciesMatches(3);
#             $this->debug['generateResponse'][] = "3 (temp_species_count:$temp_species_count)";
#           }
#     
#           if( $temp_species_count > 0 && $this->search_mode == 'no_shaping' ) {
#             $this->debug['generateResponse'][] = "4 (getSpeciesAuthority:near_3) ($this->this_authority)";
#             $this->getSpeciesAuthority( 3, 'near_3', $this->this_authority );
#     
#             if( $this->species_found == 'Y' ) {
#               $temp_species_count = $this->db->countSpeciesMatches(4);
#             }
#     
#             if( $temp_species_count > 0 && $this->search_mode == 'no_shaping') {
#               $this->debug['generateResponse'][] = "4 (getSpeciesAuthority:near_4) ($this->this_authority)";
#               $this->getSpeciesAuthority( 4, 'near_4', $this->this_authority );
#             }
#           } // END temp_species_count > 0 and "no_shaping"
#           
#         } // END If this_search_species
#         
#         if(!is_array($this->output['species']) && $this->this_search_species != '') {$this->output['species'] = array();}
#         if($this->output_type == 'rest') {
#           if($this->debug_flag) {
#             $this->data = json_encode( array( 'success' => true, 'cache' => $cache, 'data' => $this->output, 'debug' => $this->debug ) );
#           } else {
#             $this->data = json_encode( array( 'success' => true, 'cache' => $cache, 'data' => $this->output));
#           }
#         } else {
#           $this->data = $this->output;
#         }
#   
#         if($this->cache_flag == true) {
#           if( ! $this->_cache->cache_exists()) {
#             if($this->debug_flag) {
#               $op_array = array (
#                 'success' => true
#                 , 'cache_date' => date('Y-m-d')
#                 , 'data' => $this->output
#                 , 'debug' => $this->debug
#               );
#             } else {
#               $op_array = array (
#                 'success' => true
#                 , 'cache_date' => date('Y-m-d')
#                 , 'data' => $this->output
#               );
#       
#             }
#             $op = json_encode($op_array);
#             $this->_cache->update($op);
#             $tmp_cache_key = $this->_cache->getKey();
#             $this->_cache->setKey($tmp_cache_key . '_debug');
#             $dbg = @json_encode($this->debug);
#             $this->_cache->update($dbg);
#             $this->_cache->setKey($tmp_cache_key);
#           }
#         }
#       }
#   
#       return true;
#   
#     }
