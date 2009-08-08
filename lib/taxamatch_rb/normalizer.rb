# encoding: UTF-8

module Taxamatch
  
  module Normalizer
    def self.normalize(string)
      utf8_to_ascii(string).upcase
    end
  
    def self.normalize_word(word)
      self.normalize(word).gsub(/[^A-Z0-9\-]/, '').strip
    end
    
    def self.normalize_author(string)
      self.normalize(string).gsub(/[^A-Z]/, ' ').gsub(/[\s]{2,}/, ' ').strip
    end

  protected
    def self.utf8_to_ascii(string)
      string = string.gsub(/[ÀÂÅÃÄÁẤẠ]/, "A")
      string = string.gsub(/[ÉÈÊË]/, "E")
      string = string.gsub(/[ÍÌÎÏ]/, "I")
      string = string.gsub(/[ÓÒÔØÕÖỚỔ]/, "O")
      string = string.gsub(/[ÚÙÛÜ]/, "U")
      string = string.gsub(/[Ý]/, "Y")
      string = string.gsub(/Æ/, "AE")
      string = string.gsub(/[ČÇ]/, "C")
      string = string.gsub(/[ŠŞ]/, "S")
      string = string.gsub(/[Đ]/, "D")
      string = string.gsub(/Ž/, "Z")
      string = string.gsub(/Ñ/, "N")
      string = string.gsub(/Œ/, "OE")
      string = string.gsub(/ß/, "B")
      string = string.gsub(/Ķ/, "K")
      string = string.gsub(/[áàâåãäăãắảạậầằ]/, "a")
      string = string.gsub(/[éèêëĕěếệểễềẻ]/, "e")
      string = string.gsub(/[íìîïǐĭīĩỉï]/, "i")
      string = string.gsub(/[óòôøõöŏỏỗộơọỡốơồờớổ]/, "o")
      string = string.gsub(/[úùûüůưừựủứụ]/, "u")
      string = string.gsub(/[žź]/, "z")
      string = string.gsub(/[ýÿỹ]/, "y")
      string = string.gsub(/[đ]/, "d")
      string = string.gsub(/æ/, "ae")
      string = string.gsub(/[čćç]/, "c")
      string = string.gsub(/[ñńň]/, "n")
      string = string.gsub(/œ/, "oe")
      string = string.gsub(/[śšş]/, "s")
      string = string.gsub(/ř/, "r")
      string = string.gsub(/ğ/, "g")
      string = string.gsub(/Ř/, "R")
    end

  end

end