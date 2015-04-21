require "coveralls"
Coveralls.wear!

require "rspec"
$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "taxamatch_rb"

def read_test_file(file, fields_num)
  f = open(file)
  f.each do |line|
    fields = line.split("|")
    if line.match(/^\s*#/).nil? && fields.size == fields_num
      fields[-1] = fields[-1].split("#")[0].strip
      yield(fields)
    else
      yield(nil)
    end
  end
end

def make_taxamatch_hash(string)
  normalized = Taxamatch::Normalizer.normalize(string)
  { string: string, normalized: normalized,
    phonetized: Taxamatch::Phonetizer.near_match(normalized) }
end
