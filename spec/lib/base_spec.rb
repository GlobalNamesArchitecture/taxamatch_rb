describe Taxamatch::Base do
  subject { Taxamatch::Base.new }

  describe "#taxamatch" do
    it "fuzzy matches two strings" do
      expect(subject.taxamatch("Homo sapiens", "Homo sapien")).to be true
    end

    context "return not boolean" do
      it "fuzzy matches two strings and returns hash" do
        expect(subject.taxamatch("Homo sapiens", "Homo sapien", false)).
          to eq("edit_distance" => 1, "match" => true,
                "phonetic_match" => false)
      end
    end
  end
end

describe "Taxamatch::Base" do
  subject { Taxamatch::Base.new }

  it "gets txt tests" do
    test_file = File.join(__dir__, "..", "files", "taxamatch_test.txt")
    read_test_file(test_file, 4) do |y|
      if y
        y[2] = (y[2] == "true") ? true : false
        res = subject.taxamatch(y[0], y[1], false)
        # puts "%s, %s, %s, %s" % [y[0], y[1], y[2], y[3]]
        expect(res["match"]).to eq y[2]
        expect(res["edit_distance"]).to eq y[3].to_i
      end
    end
  end

  # TODO: This case might show a problem
  it "works with 'dirty' names" do
    res = subject.taxamatch("Quadraspidiotus ostreaeformis MacGillivray, 1921",
                        "Quadraspidiotus ostreaeformis Curtis)))")
    expect(res).to be true
  end

  it "should compare genera" do
    # edit distance 1 always match
    g1 = make_taxamatch_hash "Plantago"
    g2 = make_taxamatch_hash "Plantagon"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false, 
                                              "edit_distance" => 1,
                                              "match" => true)
    # edit_distance above threshold does not math
    g1 = make_taxamatch_hash "Plantago"
    g2 = make_taxamatch_hash "This shouldnt match"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false,
                                              "match" => false, 
                                              "edit_distance" => 4)
    # phonetic_match matches
    g1 = make_taxamatch_hash "Plantagi"
    g2 = make_taxamatch_hash "Plantagy"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => true,
                                              "edit_distance" => 1,
                                              "match" => true )
    expect(subject.match_genera(g1, g2, with_phonetic_match: false)).to eq(
      "phonetic_match" => false, "edit_distance" => 1, "match" => true
    )
    # distance 1 in first letter also matches
    g1 = make_taxamatch_hash "Xantheri"
    g2 = make_taxamatch_hash "Pantheri"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false,
                                              "edit_distance" => 1,
                                              "match" => true)
    # phonetic match tramps everything
    g1 = make_taxamatch_hash "Xaaaaantheriiiiiiiiiiiiiii"
    g2 = make_taxamatch_hash "Zaaaaaaaaaaaantheryyyyyyyy"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => true,
                                              "edit_distance" => 4,
                                              "match" => true )
    expect(subject.match_genera(g1, g2, with_phonetic_match: false)).to eq(
      "phonetic_match" => false, "edit_distance" => 4, "match" => false
    )
    # same first letter and distance 2 should match
    g1 = make_taxamatch_hash "Xaaaantherii"
    g2 = make_taxamatch_hash "Xaaaantherrr"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false,
                                              "match" => true,
                                              "edit_distance" => 2)
    # First letter is the same and distance is 3 should match, no phonetic match
    g1 = make_taxamatch_hash "Xaaaaaaaaaaantheriii"
    g2 = make_taxamatch_hash "Xaaaaaaaaaaantherrrr"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false, 
                                              "match" => true,
                                              "edit_distance" => 3)
    # Should not match if one of words is shorter than 2x edit
    # distance and distance is 2 or 3
    g1 = make_taxamatch_hash "Xant"
    g2 = make_taxamatch_hash "Xanthe"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false,
                                              "match" => false,
                                              "edit_distance" => 2)
    # Should not match if edit distance > 3 and no phonetic match
    g1 = make_taxamatch_hash "Xantheriiii"
    g2 = make_taxamatch_hash "Xantherrrrr"
    expect(subject.match_genera(g1, g2)).to eq("phonetic_match" => false,
                                              "match" => false,
                                              "edit_distance" => 4)
  end

  it "should compare species" do
    # Exact match
    s1 = make_taxamatch_hash "major"
    s2 = make_taxamatch_hash "major"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => true,
                                                "match" => true,
                                                "edit_distance" => 0) 
    expect(subject.match_species(s1, s2, with_phonetic_match: false)).to eq(
      "phonetic_match" => false, "match" => true, "edit_distance" => 0
    )
    # Phonetic match always works
    s1 = make_taxamatch_hash "xanteriiieeeeeeeeeeeee"
    s2 = make_taxamatch_hash "zantereeeeeeeeeeeeeeee"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => true,
                                                "match" => true,
                                                "edit_distance" => 4)
    expect(subject.match_species(s1, s2, with_phonetic_match: false)).to eq(
      "phonetic_match" => false, "match" => false, "edit_distance" => 4 
    )
    # Phonetic match works with different endings
    s1 = make_taxamatch_hash "majorum"
    s2 = make_taxamatch_hash "majoris"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => true,
                                                "match" => true,
                                                "edit_distance" => 2)
    expect(subject.match_species(s1, s2, with_phonetic_match: false)).to eq(
      "phonetic_match" => false, "match" => true, "edit_distance" => 2 
    )
    # Distance 4 matches if first 3 chars are the same
    s1 = make_taxamatch_hash "majjjjorrrrr"
    s2 = make_taxamatch_hash "majjjjoraaaa"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => true,
                                                "edit_distance" => 4)
    # Should not match if Distance 4 matches and first 3 chars are not the same
    s1 = make_taxamatch_hash "majorrrrr"
    s2 = make_taxamatch_hash "marorraaa"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => false,
                                                "edit_distance" => 4)
    # Distance 2 or 3 matches if first 1 char is the same
    s1 = make_taxamatch_hash "moooorrrr"
    s2 = make_taxamatch_hash "mooooraaa"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => true,
                                                "edit_distance" => 3)
    # Should not match if Distance 2 or 3 and first 1 char is not the same
    s1 = make_taxamatch_hash "morrrr"
    s2 = make_taxamatch_hash "torraa"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => false,
                                                "edit_distance" => 3)
    # Distance 1 will match anywhere
    s1 = make_taxamatch_hash "major"
    s2 = make_taxamatch_hash "rajor"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => true,
                                                "edit_distance" => 1)
    # Will not match if distance 3 and length is less then twice
    # of the edit distance
    s1 = make_taxamatch_hash "marrr"
    s2 = make_taxamatch_hash "maaaa"
    expect(subject.match_species(s1, s2)).to eq("phonetic_match" => false,
                                                "match" => false,
                                                "edit_distance" => 3)
  end

  it "should match matches" do
    # No trobule case
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => true, "edit_distance" => 2, "match" => true
    )
    # Will not match if either genus or sp. epithet dont match
    gmatch = { "match" => false,
      "phonetic_match" => false, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => true, "edit_distance" => 1 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => false, "edit_distance" => 2, "match" => false
    )
    gmatch = { "match" => true, "phonetic_match" => true,
      "edit_distance" => 1 }
    smatch = { "match" => false, "phonetic_match" => false,
      "edit_distance" => 1 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => false, "edit_distance" => 2, "match" => false
    )
    # Should not match if binomial edit distance > 4
    # NOTE: EVEN with full phonetic match
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 3 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => true, "edit_distance" => 5, "match" => false
    )
    # Should not have phonetic match if one of the components
    # does not match phonetically
    gmatch = { "match" => true,
      "phonetic_match" => false, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => true, "edit_distance" => 1 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => false, "edit_distance" => 2, "match" => true
    )
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => false, "edit_distance" => 1 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match" => false, "edit_distance" => 2, "match" => true
    )
    # edit distance should be equal the sum of of edit distances
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    expect(subject.match_matches(gmatch, smatch)).to eq(
      "phonetic_match"=>true, "edit_distance"=>4, "match"=>true
    )
  end

  it "returns only boolean values" do
    expect(subject.taxamatch("AJLJljljlj", "sls")).to_not be_nil
    expect(subject.taxamatch("Olsl","a")).to be false
  end

  it "should not match authors from different parts of name" do
    parser = Taxamatch::Atomizer.new
    n1 = parser.parse "Betula Linnaeus"
    n2 = parser.parse "Betula alba Linnaeus"
    n3 = parser.parse "Betula alba alba Linnaeus"
    n4 = parser.parse "Betula alba L."
    n5 = parser.parse "Betula alba"
    n6 = parser.parse "Betula olba"
    n7 = parser.parse "Betula alba Linnaeus alba"
    n8 = parser.parse "Betula alba Linnaeus alba Smith"
    n9 = parser.parse "Betula alba Smith alba L."
    n10 = parser.parse "Betula Linn."
    # if one authorship is empty, return true
    expect(subject.match_authors(n1, n5)).to be 0
    expect(subject.match_authors(n5, n1)).to be 0
    expect(subject.match_authors(n5, n6)).to be 0
    # if authorship matches on different levels ignore
    expect(subject.match_authors(n7, n3)).to be 0
    expect(subject.match_authors(n8, n3)).to be -1
    expect(subject.match_authors(n2, n8)).to be 0
    expect(subject.match_authors(n1, n2)).to be 0
    # match on infraspecies level
    expect(subject.match_authors(n9, n3)).to be 1
    # match on species level
    expect(subject.match_authors(n2, n4)).to be 1
    # match on uninomial level
    expect(subject.match_authors(n1, n10)).to be 1
  end
end
