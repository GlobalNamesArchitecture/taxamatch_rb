describe Taxamatch::Normalizer do
  it "normalizes  strings" do
    [
      ["abcd", "ABCD"],
      ["Leœptura", "LEOEPTURA"],
      ["Ærenea", "AERENEA"],
      ["Fallén", "FALLEN"],
      ["Fallé€n", "FALLE?N"],
      ["Fallén привет", "FALLEN ??????"],
      ["Choriozopella trägårdhi", "CHORIOZOPELLA TRAGARDHI"],
      ["×Zygomena", "xZYGOMENA"]
    ].each do |input, output|
      expect(subject.normalize(input)).to eq output
    end
  end

  it "normalizes words" do
    expect(subject.normalize_word("L-3eœ|pt[ura$")).to eq "L-3EOEPTURA"
  end
end

