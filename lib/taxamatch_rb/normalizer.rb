# encoding: UTF-8
require 'unicode_utils/upcase'

module Normalizer
  def self.normalize(string)
    string = UnicodeUtils.upcase(string)
    string = string.tr('ÁÉÍÓÚÀÈÌÒÙÂÊÎÔÛÄËÏÖÜÃÑÕÅÇØ','AEIOUAEIOUAEIOUAEIOUANOACO')
    string = string.gsub('Æ', 'AE')
    string = string.gsub('Œ', 'OE')
  end
end