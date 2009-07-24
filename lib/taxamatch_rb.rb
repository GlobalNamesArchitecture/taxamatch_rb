$:.unshift(File.dirname(__FILE__)) unless
   $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'taxamatch_rb/damerau_levenshtein_mod'
require 'taxamatch_rb/parser'

module TaxamatchRb
end
