describe Taxamatch::Authmatch do
  subject { Taxamatch::Authmatch }
  it "should calculate score" do
    res = subject.authmatch(["Linnaeus", "Muller"], ["L"], [], [1788])
    expect(res).to be 90
    res = subject.authmatch(["Linnaeus"],["Kurtz"], [], [])
    expect(res).to be 0
    # found all authors, same year
    res = subject.authmatch(["Linnaeus", "Muller"],
                        ["Muller", "Linnaeus"], [1766], [1766])
    expect(res).to be 100
    # all authors, 1 year diff
    res = subject.authmatch(["Linnaeus", "Muller"],
                        ["Muller", "Linnaeus"], [1767], [1766])
    expect(res).to be 54
    # year is not counted in
    res = subject.authmatch(["Linnaeus", "Muller"],
                        ["Muller", "Linnaeus"], [1767], [])
    expect(res).to be 94
    # found all authors on one side, same year
    res = subject.authmatch(["Linnaeus", "Muller", "Kurtz"],
                        ["Muller", "Linnaeus"], [1767], [1767])
    expect(res).to be 91
    # found all authors on one side, 1 year diff
    res = subject.authmatch(["Linnaeus", "Muller", "Kurtz"],
                        ["Muller", "Linnaeus"], [1766], [1767])
    expect(res).to be 51
    # found all authors on one side, year does not count
    res = subject.authmatch(["Linnaeus", "Muller"],
                        ["Muller", "Linnaeus", "Kurtz"], [1766], [])
    expect(res).to be 90
    # found some authors
    res = subject.authmatch(["Stepanov", "Linnaeus", "Muller"],
                        ["Muller", "Kurtz", "Stepanov"], [1766], [])
    expect(res).to be 67
    # if year does not match or not present no match for previous case
    res = subject.authmatch(["Stepanov", "Linnaeus", "Muller"],
                        ["Muller", "Kurtz", "Stepanov"], [1766], [1765])
    expect(res).to be 0
  end

  it "should compare years" do
    expect(subject.compare_years([1882],[1880])).to be 2
    expect(subject.compare_years([1882],[])).to be nil
    expect(subject.compare_years([],[])).to be 0
    expect(subject.compare_years([1788,1798], [1788,1798])).to be nil
  end

  it "removes duplicate authors" do
    # Lin submatches Linnaeus and it its size 3 is big enough to remove
    # Muller, Muller are identical
    res = subject.remove_duplicate_authors(["Lin", "Muller"],
                                       ["Linnaeus", "Muller"])
    expect(res).to eq [[], []]
    # same in different order
    res = subject.remove_duplicate_authors(["Linnaeus", "Muller"],
                                       ["Linn", "Muller"])
    expect(res).to eq [[], []]
    # auth Li submatches Linnaeus, but Li size less then 3
    # required to remove Linnaeus
    res = subject.remove_duplicate_authors(["Dem", "Li"],
                                       ["Linnaeus", "Stepanov"])
    expect(res).to eq [["Dem"], ["Linnaeus", "Stepanov"]]
    # fuzzy match
    res = subject.remove_duplicate_authors(["Dem", "Lennaeus"],
                                       ["Linnaeus", "Stepanov"])
    expect(res).to eq [["Dem"], ["Stepanov"]]
    res = subject.remove_duplicate_authors(["Linnaeus", "Muller"],
                                       ["L", "Kenn"])
    expect(res).to eq [["Linnaeus", "Muller"], ["Kenn"]]
    res = subject.remove_duplicate_authors(["Linnaeus", "Muller"],
                                       ["Muller", "Linnaeus", "Kurtz"])
    expect(res).to eq [[],["Kurtz"]]
  end

  it "should fuzzy match authors" do
    res = subject.fuzzy_match_authors("L", "Muller")
    expect(res).to be false
  end
end

