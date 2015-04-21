require "taxamatch_rb/version"
require "damerau-levenshtein"
require "taxamatch_rb/base"
require "taxamatch_rb/atomizer"
require "taxamatch_rb/normalizer"
require "taxamatch_rb/phonetizer"
require "taxamatch_rb/authmatch"

if RUBY_VERSION < "1.9.1"
  fail "IMPORTANT: Parsley-store gem  requires ruby >= 1.9.1"
end

# encoding: utf-8
# Taxamatch is a namespace module
module Taxamatch
end
