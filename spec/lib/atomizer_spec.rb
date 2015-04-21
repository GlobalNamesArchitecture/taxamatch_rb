describe Taxamatch::Atomizer do
  before(:all) do
    @parser = Taxamatch::Atomizer.new
  end

  it "should parse uninomials" do
    @parser.parse("Betula").should == { all_authors: [], all_years: [],
      canonical_form: "Betula", uninomial: { string: "Betula",
      normalized: "BETULA", phonetized: "BITILA", authors: [],
      years: [], normalized_authors: [] } }
    @parser.parse("Ærenea Lacordaire, 1872").should == {
      all_authors: ["LACORDAIRE"], all_years: [1872],
      canonical_form: "Aerenea", uninomial: { string: "Aerenea",
        normalized: "AERENEA", phonetized: "ERINIA",
        authors: ["Lacordaire"], years: [1872],
        normalized_authors: ["LACORDAIRE"] } }
  end

  it "should parse binomials" do
    @parser.parse("Leœptura laetifica Dow, 1913").should == {
      all_authors: ["DOW"], all_years: [1913],
      canonical_form: "Leoeptura laetifica", genus: {
      string: "Leoeptura", normalized: "LEOEPTURA",
      phonetized: "LIPTIRA", authors: [], years: [],
      normalized_authors: []}, species: {
      string: "laetifica", normalized: "LAETIFICA",
      phonetized: "LITIFICA", authors: ["Dow"],
      years: [1913], normalized_authors: ["DOW"] } }
  end

  it "should parse trinomials" do
    @parser.parse("Hydnellum scrobiculatum zonatum " +
                  "(Banker) D. Hall et D.E. Stuntz 1972").should ==  {
      all_authors: ["BANKER", "D HALL", "D E STUNTZ"], all_years: [1972],
      canonical_form: "Hydnellum scrobiculatum zonatum", :genus=>{
      string: "Hydnellum", normalized: "HYDNELLUM",
      phonetized: "HIDNILIM", authors: [], years: [],
      normalized_authors: [] }, species: { string: "scrobiculatum",
      normalized: "SCROBICULATUM", phonetized: "SCRABICILATA",
      authors: [], years: [], normalized_authors: [] },
      infraspecies: [{ string: "zonatum", normalized: "ZONATUM",
      phonetized: "ZANATA", authors: ["Banker", "D. Hall", "D.E. Stuntz"],
      years: [1972], normalized_authors: ["BANKER", "D HALL",
      "D E STUNTZ"] }] }
  end

  it "should normalize years to integers" do
    future_year = Time.now.year + 10
    @parser.parse("Hydnellum scrobiculatum Kern #{future_year} " +
                  "zonatum (Banker) D. Hall et D.E. Stuntz 1972?").should == {
      all_authors: ["KERN", "BANKER", "D HALL", "D E STUNTZ"],
      all_years: [1972],
      canonical_form: "Hydnellum scrobiculatum zonatum", genus: {
      string: "Hydnellum", normalized: "HYDNELLUM",
      phonetized: "HIDNILIM", authors: [], years: [],
      normalized_authors: [] }, species: { string: "scrobiculatum",
      normalized: "SCROBICULATUM", phonetized: "SCRABICILATA",
      authors: ["Kern"], years: [], normalized_authors: ["KERN"] },
      infraspecies: [{ string: "zonatum", normalized: "ZONATUM",
      phonetized: "ZANATA", authors:
      ["Banker", "D. Hall", "D.E. Stuntz"], years: [1972],
      normalized_authors: ["BANKER", "D HALL", "D E STUNTZ"] }] }
  end

  it "should normalize names with abbreviated genus after cf." do
    @parser.parse("Unio cf. U. alba").should == { all_authors: [],
      all_years: [], canonical_form: "Unio",
      genus: { string: "Unio", normalized: "UNIO",
      phonetized: "UNIA", authors: [], years: [],
      normalized_authors: [] } }
  end

  it "should parse names which broke it before" do
    ["Parus caeruleus species complex",
     "Euxoa nr. idahoensis sp. 1clay",
     "Cetraria islandica ? islandica",
     "Buteo borealis ? ventralis"].each do |n|
      res = @parser.parse(n)
      res.class.should == Hash
      expect(res.empty?).to be false
    end
  end
end
