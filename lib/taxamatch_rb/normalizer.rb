# encoding: UTF-8

module Taxamatch
  
  module Normalizer
    def self.normalize(string)
      utf8_to_ascii(string.strip.upcase).gsub(/[^\x00-\x7F]/,'?')
    end
  
    def self.normalize_word(word)
      self.normalize(word).gsub(/[^A-Z0-9\-]/, '').strip
    end
    
    def self.normalize_author(string)
      self.normalize(string).gsub(/[^A-Z]/, ' ').gsub(/[\s]{2,}/, ' ').strip
    end

    def self.normalize_year(year_string)
      year_int = year_string.gsub(/[^\d]/, '').to_i
      year_int = nil unless year_int.between?(1757, Time.now.year + 1)
      year_int
    end
      

  private
    def self.utf8_to_ascii(string)
      string = string.gsub(/\s{2,}/, ' ')
      string = string.gsub("×", "x")
      string = string.gsub(/[ÀÂÅÃÄÁẤẠÁáàâåãäăãắảạậầằá]/, "A")
      string = string.gsub(/[ÉÈÊËéèêëĕěếệểễềẻ]/, "E")
      string = string.gsub(/[ÍÌÎÏíìîïǐĭīĩỉï]/, "I")
      string = string.gsub(/[ÓÒÔØÕÖỚỔóòôøõöŏỏỗộơọỡốơồờớổő]/, "O")
      string = string.gsub(/[ÚÙÛÜúùûüůưừựủứụű]/, "U")
      string = string.gsub(/[Ýýÿỹ]/, "Y")
      string = string.gsub(/[Ææ]/, "AE")
      string = string.gsub(/[ČÇčćç]/, "C")
      string = string.gsub(/[ŠŞśšşſ]/, "S")
      string = string.gsub(/[Đđð]/, "D")
      string = string.gsub(/Žžź/, "Z")
      string = string.gsub(/[Ññńň]/, "N")
      string = string.gsub(/[Œœ]/, "OE")
      string = string.gsub(/ß/, "B")
      string = string.gsub(/Ķ/, "K")
      string = string.gsub(/ğ/, "G")
      string = string.gsub(/[Řř]/, "R")
    end

  end

end
