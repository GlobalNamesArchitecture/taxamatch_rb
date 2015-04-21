describe "Taxamatch::Normalizer" do
  it "should normalize  strings" do
    Taxamatch::Normalizer.normalize("abcd").should == "ABCD"
    Taxamatch::Normalizer.normalize("Leœptura").should == "LEOEPTURA"
    Taxamatch::Normalizer.normalize("Ærenea").should == "AERENEA"
    Taxamatch::Normalizer.normalize("Fallén").should == "FALLEN"
    Taxamatch::Normalizer.normalize("Fallé€n").should == "FALLE?N"
    Taxamatch::Normalizer.normalize("Fallén привет").should == "FALLEN ??????"
    Taxamatch::Normalizer.normalize("Choriozopella trägårdhi").should ==
      "CHORIOZOPELLA TRAGARDHI"
    Taxamatch::Normalizer.normalize("×Zygomena").should == "xZYGOMENA"
  end

  it "should normalize words" do
    Taxamatch::Normalizer.normalize_word("L-3eœ|pt[ura$").should ==
      "L-3EOEPTURA"
  end
end

