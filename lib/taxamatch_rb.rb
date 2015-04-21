# encoding: utf-8
require "taxamatch_rb/version"
require "damerau-levenshtein"
require "taxamatch_rb/base"
require "taxamatch_rb/atomizer"
require "taxamatch_rb/normalizer"
require "taxamatch_rb/phonetizer"
require "taxamatch_rb/authmatch"

if RUBY_VERSION < "1.9.1"
  fail "IMPORTANT: taxamatch_rb gem requires ruby >= 1.9.1"
end

# Taxamatch provides fuzzy comparison between two scientific names
module Taxamatch
end
