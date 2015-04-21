describe Taxamatch::Atomizer do
  subject { Taxamatch::Atomizer.new }

  it "parses uninomials" do
    expect(subject.parse("Betula")).to eq(all_authors: [], all_years: [],
      canonical_form: "Betula", uninomial: { string: "Betula",
      normalized: "BETULA", phonetized: "BITILA", authors: [],
      years: [], normalized_authors: [] })

    expect(subject.parse("Ærenea Lacordaire, 1872")).to eq(
      all_authors: ["LACORDAIRE"], all_years: [1872],
      canonical_form: "Aerenea", uninomial: { string: "Aerenea",
        normalized: "AERENEA", phonetized: "ERINIA",
        authors: ["Lacordaire"], years: [1872],
        normalized_authors: ["LACORDAIRE"] })
  end

  it "parses binomials" do
    expect(subject.parse("Leœptura laetifica Dow, 1913")).to eq(
      all_authors: ["DOW"], all_years: [1913],
      canonical_form: "Leoeptura laetifica", genus: {
      string: "Leoeptura", normalized: "LEOEPTURA",
      phonetized: "LIPTIRA", authors: [], years: [],
      normalized_authors: []}, species: {
        string: "laetifica", normalized: "LAETIFICA",
        phonetized: "LITIFICA", authors: ["Dow"],
        years: [1913], normalized_authors: ["DOW"] })
  end

  it "parses trinomials" do
    expect(subject.parse(
      "Hydnellum scrobiculatum zonatum " \
      "(Banker) D. Hall et D.E. Stuntz 1972")).to eq(
        all_authors: ["BANKER", "D HALL", "D E STUNTZ"],
        all_years: [1972], canonical_form: "Hydnellum scrobiculatum zonatum",
        :genus=>{ string: "Hydnellum", normalized: "HYDNELLUM",
                  phonetized: "HIDNILIM", authors: [], years: [],
                  normalized_authors: [] }, 
        species: { string: "scrobiculatum",
                   normalized: "SCROBICULATUM", phonetized: "SCRABICILATA",
                   authors: [], years: [], normalized_authors: [] },
                   infraspecies: [{ string: "zonatum", normalized: "ZONATUM",
                   phonetized: "ZANATA", 
                   authors: ["Banker", "D. Hall", "D.E. Stuntz"],
                   years: [1972], normalized_authors: ["BANKER", "D HALL",
                                                       "D E STUNTZ"] }] )
  end

  it "normalizes years to integers" do
    future_year = Time.now.year + 10
    expect(subject.parse("Hydnellum scrobiculatum Kern #{future_year} " +
           "zonatum (Banker) D. Hall et D.E. Stuntz 1972?")).to eq(
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
      normalized_authors: ["BANKER", "D HALL", "D E STUNTZ"] }]) 
  end

  it "normalizes names with abbreviated genus after cf." do
    expect(subject.parse("Unio cf. U. alba")).to eq(all_authors: [],
      all_years: [], canonical_form: "Unio",
      genus: { string: "Unio", normalized: "UNIO",
      phonetized: "UNIA", authors: [], years: [],
      normalized_authors: [] }) 
  end

  it "parses names which broke it before" do
    ["Chaetomorpha linum (O.F. Müller) Kützing",
     "Parus caeruleus species complex",
     "Euxoa nr. idahoensis sp. 1clay",
     "Cetraria islandica ? islandica",
     "Buteo borealis ? ventralis"].each do |n|
       res = subject.parse(n)
       expect(res).to be_kind_of(Hash)
       expect(res.empty?).to be false
    end
  end
end
