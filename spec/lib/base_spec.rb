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
