# encoding: UTF-8
module Taxamatch

  module Phonetizer
    
    def self.phonetize(a_word, normalize_ending = false)
      self.near_match(a_word, normalize_ending)
    end
    
    def self.near_match(a_word, normalize_ending = false)
      a_word = a_word.strip rescue ''
      return '' if a_word == ''
      a_word = Taxamatch::Normalizer.normalize a_word
      case a_word
        when /^AE/
          a_word = 'E' + a_word[2..-1]
        when /^CN/
          a_word = 'N' + a_word[2..-1]
        when /^CT/
          a_word = 'T' + a_word[2..-1]
        when /^CZ/
          a_word = 'C' + a_word[2..-1]
        when /^DJ/
          a_word = 'J' + a_word[2..-1]
        when /^EA/
          a_word = 'E' + a_word[2..-1]
        when /^EU/
          a_word = 'U' + a_word[2..-1]
        when /^GN/
          a_word = 'N' + a_word[2..-1]
        when /^KN/
          a_word = 'N' + a_word[2..-1]
        when /^MC/
          a_word = 'MAC' + a_word[2..-1]
        when /^MN/
          a_word = 'N' + a_word[2..-1]
        when /^OE/
          a_word = 'E' + a_word[2..-1]
        when /^QU/
          a_word = 'Q' + a_word[2..-1]
        when /^PS/
          a_word = 'S' + a_word[2..-1]
        when /^PT/
          a_word = 'T' + a_word[2..-1]
        when /^TS/
          a_word = 'S' + a_word[2..-1]
        when /^WR/
          a_word = 'R' + a_word[2..-1]
        when /^X/
          a_word = 'Z' + a_word[1..-1]
      end
      first_char = a_word.split('')[0]
      rest_chars = a_word.split('')[1..-1].join('')   
      rest_chars.gsub!('AE', 'I')
      rest_chars.gsub!('IA', 'A')
      rest_chars.gsub!('OE', 'I')
      rest_chars.gsub!('OI', 'A')
      rest_chars.gsub!('SC', 'S')
      rest_chars.gsub!('H', '')
      rest_chars.tr!('EOUYKZ', 'IAIICS')
      a_word = (first_char + rest_chars).squeeze
    
      if normalize_ending && a_word.size > 4
        a_word = self.normalize_ending(a_word)
      end
      a_word
    end
    
    def self.normalize_ending(a_word)
        # -- deal with variant endings -is (includes -us, -ys, -es), -im (was -um), -as (-os)
        # -- at the end of a string translate all to -a
        a_word.gsub!(/IS$/, 'A')
        a_word.gsub!(/IM$/, 'A')
        a_word.gsub(/AS$/, 'A')
    end
  
  end

end