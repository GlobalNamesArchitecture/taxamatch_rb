# encoding: UTF-8

require 'damerau_levenshtein'

module Taxamatch

  class DamerauLevenshteinMod
    include DamerauLevenshtein

    def distance(str1, str2, block_size=2, max_distance=10)
      distance_utf(str1.unpack("U*"), str2.unpack("U*"), block_size, max_distance)
    end
  end

end

if __FILE__ == $0

  a = Taxamatch::DamerauLevenshteinMod.new
  s = 'Cedarinia scabra Sjöstedt 1921'.unpack('U*')
  t = 'Cedarinia scabra Söjstedt 1921'.unpack('U*')

  #puts s.join(",")
  #puts t.join(",")

  start = Time.now
  (1..100000).each do
   a.distance('Cedarinia scabra Sjöstedt 1921', 'Cedarinia scabra Söjstedt 1921',1,10)
  end
  puts "with unpack time: " + (Time.now - start).to_s + ' sec'

  start = Time.now
  (1..100000).each do
   a.distance_utf(s, t, 1, 10)
  end
  puts 'utf time: ' + (Time.now - start).to_s + ' sec'

  #puts a.distance('Cedarinia scabra Sjöstedt 1921','Cedarinia scabra Söjstedt 1921')
  #puts a.distance_utf(s, t, 2, 10)
  #puts a.distance('tar','atp',1,10);
  puts a.distance('sub', 'usb', 1, 10);
end
