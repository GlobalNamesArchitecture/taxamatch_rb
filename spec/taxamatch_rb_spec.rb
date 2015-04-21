# encoding: utf-8


describe Taxamatch do
  subject { Taxamatch }

  describe ".version" do
    it 'returns taxamatch_rb version' do
      expect(subject.version).to match /^[\d]+\.[\d]+\.[\d]+$/
    end
  end
end
