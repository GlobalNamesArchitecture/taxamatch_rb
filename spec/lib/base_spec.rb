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
  before(:all) do
    @tm = Taxamatch::Base.new
  end

  it "should get txt tests" do
    test_file = File.join(__dir__, "..", "files", "taxamatch_test.txt")
    read_test_file(test_file, 4) do |y|
      if y
        y[2] = y[2] == "true" ? true : false
        res = @tm.taxamatch(y[0], y[1], false)
        # puts "%s, %s, %s, %s" % [y[0], y[1], y[2], y[3]]
        res["match"].should == y[2]
        res["edit_distance"].should == y[3].to_i
      end
    end
  end

  it "should work with names that cannot be parsed" do
    res = @tm.taxamatch("Quadraspidiotus ostreaeformis MacGillivray, 1921",
                        "Quadraspidiotus ostreaeformis Curtis)")
    res = false
  end

  it "should compare genera" do
    # edit distance 1 always match
    g1 = make_taxamatch_hash "Plantago"
    g2 = make_taxamatch_hash "Plantagon"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => false,
      "edit_distance" => 1, "match" => true }
    # edit_distance above threshold does not math
    g1 = make_taxamatch_hash "Plantago"
    g2 = make_taxamatch_hash "This shouldnt match"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => false,
      "match" => false, "edit_distance" => 4 }
    # phonetic_match matches
    g1 = make_taxamatch_hash "Plantagi"
    g2 = make_taxamatch_hash "Plantagy"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => true,
      "edit_distance" => 1, "match" => true }
    @tm.match_genera(g1, g2, with_phonetic_match: false).should == {
      "phonetic_match" => false, "edit_distance" => 1, "match" => true }
    # distance 1 in first letter also matches
    g1 = make_taxamatch_hash "Xantheri"
    g2 = make_taxamatch_hash "Pantheri"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => false,
      "edit_distance" => 1, "match" => true }
    # phonetic match tramps everything
    g1 = make_taxamatch_hash "Xaaaaantheriiiiiiiiiiiiiii"
    g2 = make_taxamatch_hash "Zaaaaaaaaaaaantheryyyyyyyy"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => true,
      "edit_distance" => 4, "match" => true }
    @tm.match_genera(g1, g2, with_phonetic_match: false).should == {
      "phonetic_match" => false, "edit_distance" => 4, "match" => false }
    # same first letter and distance 2 should match
    g1 = make_taxamatch_hash "Xaaaantherii"
    g2 = make_taxamatch_hash "Xaaaantherrr"
    @tm.match_genera(g1, g2).should == { "phonetic_match" => false,
      "match" => true, "edit_distance" => 2 }
    # First letter is the same and distance is 3 should match, no phonetic match
    g1 = make_taxamatch_hash "Xaaaaaaaaaaantheriii"
    g2 = make_taxamatch_hash "Xaaaaaaaaaaantherrrr"
    @tm.match_genera(g1, g2).should ==
      { "phonetic_match" => false, "match" => true, "edit_distance" => 3 }
    # Should not match if one of words is shorter than 2x edit
    # distance and distance is 2 or 3
    g1 = make_taxamatch_hash "Xant"
    g2 = make_taxamatch_hash "Xanthe"
    @tm.match_genera(g1, g2).should ==  { "phonetic_match" => false,
      "match" => false, "edit_distance" => 2 }
    # Should not match if edit distance > 3 and no phonetic match
    g1 = make_taxamatch_hash "Xantheriiii"
    g2 = make_taxamatch_hash "Xantherrrrr"
    @tm.match_genera(g1, g2).should ==  { "phonetic_match" => false,
      "match" => false, "edit_distance" => 4 }
  end

  it "should compare species" do
    # Exact match
    s1 = make_taxamatch_hash "major"
    s2 = make_taxamatch_hash "major"
    @tm.match_species(s1, s2).should ==  { "phonetic_match" => true,
      "match" => true, "edit_distance" => 0 }
    @tm.match_species(s1, s2, with_phonetic_match: false).should == {
      "phonetic_match" => false, "match" => true, "edit_distance" => 0 }
    # Phonetic match always works
    s1 = make_taxamatch_hash "xanteriiieeeeeeeeeeeee"
    s2 = make_taxamatch_hash "zantereeeeeeeeeeeeeeee"
    @tm.match_species(s1, s2).should ==  { "phonetic_match" => true,
      "match" => true, "edit_distance" => 4 }
    @tm.match_species(s1, s2, with_phonetic_match: false).should ==
      { "phonetic_match" => false, "match" => false, "edit_distance" => 4 }
    # Phonetic match works with different endings
    s1 = make_taxamatch_hash "majorum"
    s2 = make_taxamatch_hash "majoris"
    @tm.match_species(s1, s2).should ==  {
      "phonetic_match" => true, "match" => true, "edit_distance" => 2 }
    @tm.match_species(s1, s2, with_phonetic_match: false).should ==
      { "phonetic_match" => false, "match" => true, "edit_distance" => 2 }
    # Distance 4 matches if first 3 chars are the same
    s1 = make_taxamatch_hash "majjjjorrrrr"
    s2 = make_taxamatch_hash "majjjjoraaaa"
    @tm.match_species(s1, s2).should ==
      { "phonetic_match" => false, "match" => true, "edit_distance" => 4 }
    # Should not match if Distance 4 matches and first 3 chars are not the same
    s1 = make_taxamatch_hash "majorrrrr"
    s2 = make_taxamatch_hash "marorraaa"
    @tm.match_species(s1, s2).should == {
      "phonetic_match" => false, "match" => false, "edit_distance" => 4 }
    # Distance 2 or 3 matches if first 1 char is the same
    s1 = make_taxamatch_hash "moooorrrr"
    s2 = make_taxamatch_hash "mooooraaa"
    @tm.match_species(s1, s2).should == { "phonetic_match" => false,
      "match" => true, "edit_distance" => 3 }
    # Should not match if Distance 2 or 3 and first 1 char is not the same
    s1 = make_taxamatch_hash "morrrr"
    s2 = make_taxamatch_hash "torraa"
    @tm.match_species(s1, s2).should == {
      "phonetic_match" => false, "match" => false, "edit_distance" => 3 }
    # Distance 1 will match anywhere
    s1 = make_taxamatch_hash "major"
    s2 = make_taxamatch_hash "rajor"
    @tm.match_species(s1, s2).should == {
      "phonetic_match" => false, "match" => true, "edit_distance" => 1 }
    # Will not match if distance 3 and length is less then twice
    # of the edit distance
    s1 = make_taxamatch_hash "marrr"
    s2 = make_taxamatch_hash "maaaa"
    @tm.match_species(s1, s2).should == {
      "phonetic_match" => false, "match" => false, "edit_distance" => 3 }
  end

  it "should match matches" do
    # No trobule case
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    @tm.match_matches(gmatch, smatch).should ==
      { "phonetic_match" => true, "edit_distance" => 2, "match" => true }
    # Will not match if either genus or sp. epithet dont match
    gmatch = { "match" => false,
      "phonetic_match" => false, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => true, "edit_distance" => 1 }
    @tm.match_matches(gmatch, smatch).should == { "phonetic_match" => false,
      "edit_distance" => 2, "match" => false }
    gmatch = { "match" => true, "phonetic_match" => true,
      "edit_distance" => 1 }
    smatch = { "match" => false, "phonetic_match" => false,
      "edit_distance" => 1 }
    @tm.match_matches(gmatch, smatch).should == { "phonetic_match" => false,
      "edit_distance" => 2, "match" => false }
    # Should not match if binomial edit distance > 4
    # NOTE: EVEN with full phonetic match
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 3 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    @tm.match_matches(gmatch, smatch).should == { "phonetic_match" => true,
      "edit_distance" => 5, "match" => false }
    # Should not have phonetic match if one of the components
    # does not match phonetically
    gmatch = { "match" => true,
      "phonetic_match" => false, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => true, "edit_distance" => 1 }
    @tm.match_matches(gmatch, smatch).should == { "phonetic_match" => false,
      "edit_distance" => 2, "match" => true }
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 1 }
    smatch = { "match" => true,
      "phonetic_match" => false, "edit_distance" => 1 }
    @tm.match_matches(gmatch, smatch).should == { "phonetic_match" => false,
      "edit_distance" => 2, "match" => true }
    # edit distance should be equal the sum of of edit distances
    gmatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    smatch = { "match" => true, "phonetic_match" => true, "edit_distance" => 2 }
    @tm.match_matches(gmatch, smatch).should == {
      "phonetic_match"=>true, "edit_distance"=>4, "match"=>true }
  end

  it "should return only boolean values" do
    @tm.taxamatch("AJLJljljlj", "sls").should_not be_nil
    @tm.taxamatch("Olsl","a")
  end

  it "should not match authors from different parts of name" do
    parser = Taxamatch::Atomizer.new
    t = Taxamatch::Base.new
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
    t.match_authors(n1, n5).should == true
    t.match_authors(n5, n1).should == true
    t.match_authors(n5, n6).should == true
    # if authorship matches on different levels ignore
    t.match_authors(n7, n3).should == true
    t.match_authors(n8, n3).should == false
    t.match_authors(n2, n8).should == true
    t.match_authors(n1, n2).should == true
    # match on infraspecies level
    t.match_authors(n9, n3).should == true
    # match on species level
    t.match_authors(n2, n4).should == true
    # match on uninomial level
    t.match_authors(n1, n10).should == true
  end


  describe "Taxamatch::Authmatch" do
    before(:all) do
      @am = Taxamatch::Authmatch
    end

    it "should calculate score" do
      res = @am.authmatch(["Linnaeus", "Muller"], ["L"], [], [1788])
      res.should == 90
      res = @am.authmatch(["Linnaeus"],["Kurtz"], [], [])
      res.should == 0
      # found all authors, same year
      res = @am.authmatch(["Linnaeus", "Muller"],
                          ["Muller", "Linnaeus"], [1766], [1766])
      res.should == 100
      # all authors, 1 year diff
      res = @am.authmatch(["Linnaeus", "Muller"],
                          ["Muller", "Linnaeus"], [1767], [1766])
      res.should == 54
      # year is not counted in
      res = @am.authmatch(["Linnaeus", "Muller"],
                          ["Muller", "Linnaeus"], [1767], [])
      res.should == 94
      # found all authors on one side, same year
      res = @am.authmatch(["Linnaeus", "Muller", "Kurtz"],
                          ["Muller", "Linnaeus"], [1767], [1767])
      res.should == 91
      # found all authors on one side, 1 year diff
      res = @am.authmatch(["Linnaeus", "Muller", "Kurtz"],
                          ["Muller", "Linnaeus"], [1766], [1767])
      res.should == 51
      # found all authors on one side, year does not count
      res = @am.authmatch(["Linnaeus", "Muller"],
                          ["Muller", "Linnaeus", "Kurtz"], [1766], [])
      res.should == 90
      # found some authors
      res = @am.authmatch(["Stepanov", "Linnaeus", "Muller"],
                          ["Muller", "Kurtz", "Stepanov"], [1766], [])
      res.should == 67
      # if year does not match or not present no match for previous case
      res = @am.authmatch(["Stepanov", "Linnaeus", "Muller"],
                          ["Muller", "Kurtz", "Stepanov"], [1766], [1765])
      res.should == 0
    end

    it "should compare years" do
      @am.compare_years([1882],[1880]).should == 2
      @am.compare_years([1882],[]).should == nil
      @am.compare_years([],[]).should == 0
      @am.compare_years([1788,1798], [1788,1798]).should be_nil
    end

    it "should remove duplicate authors" do
      # Li submatches Linnaeus and it its size 3 is big enought to remove
      # Linnaeus Muller is identical
      res = @am.remove_duplicate_authors(["Lin", "Muller"],
                                         ["Linnaeus", "Muller"])
      res.should == [[], []]
      # same in different order
      res = @am.remove_duplicate_authors(["Linnaeus", "Muller"],
                                         ["Linn", "Muller"])
      res.should == [[], []]
      # auth Li submatches Linnaeus, but Li size less then 3
      # required to remove Linnaeus
      res = @am.remove_duplicate_authors(["Dem", "Li"],
                                         ["Linnaeus", "Stepanov"])
      res.should == [["Dem"], ["Linnaeus", "Stepanov"]]
      # fuzzy match
      res = @am.remove_duplicate_authors(["Dem", "Lennaeus"],
                                         ["Linnaeus", "Stepanov"])
      res.should == [["Dem"], ["Stepanov"]]
      res = @am.remove_duplicate_authors(["Linnaeus", "Muller"],
                                         ["L", "Kenn"])
      res.should == [["Linnaeus", "Muller"], ["Kenn"]]
      res = @am.remove_duplicate_authors(["Linnaeus", "Muller"],
                                         ["Muller", "Linnaeus", "Kurtz"])
      res.should == [[],["Kurtz"]]
    end

    it "should fuzzy match authors" do
      res = @am.fuzzy_match_authors("L", "Muller")
      expect(res).to be false
    end

  end

end
