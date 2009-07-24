#!/usr/bin/env ruby
# encoding: UTF-8
require 'rubygems'
require 'inline'
require 'time'

class DamerauLevenshteinMod
  def distance(str1, str2, block_size=2, max_distance=10)
    # puts str1.unpack("U*");
    res = distance_utf(str1.unpack("U*"), str2.unpack("U*"), block_size, max_distance)
    (res > max_distance) ? nil : res
  end

  inline do |builder|
    builder.c "
    static VALUE distance_utf(VALUE _s, VALUE _t, long block_size, long max_distance){
      long min, i, i1, j, j1, k, sl, half_sl, tl, half_tl, cost, *d, distance, del, ins, subs, transp, block, current_distance;
      long stop_execution = 0;

      VALUE *sv = RARRAY_PTR(_s);
      VALUE *tv = RARRAY_PTR(_t);
      
      sl = RARRAY_LEN(_s);
      tl = RARRAY_LEN(_t);
      
      if (sl == 0) return LONG2NUM(tl);
      if (tl == 0) return LONG2NUM(sl);
      //case of lengths 1 must present or it will break further in the code
      if (sl == 1 && tl == 1 && sv[0] != tv[0]) return LONG2NUM(1);
      
      long s[sl];
      long t[tl];
      
      for (i=0; i < sl; i++) s[i] = NUM2LONG(sv[i]);
      for (i=0; i < tl; i++) t[i] = NUM2LONG(tv[i]);
      
      sl++;
      tl++;
      
      //one-dimentional representation of 2 dimentional array len(s)+1 * len(t)+1
      d = malloc((sizeof(long))*(sl)*(tl));
      //populate 'vertical' row starting from the 2nd position (first one is filled already)
      for(i = 0; i < tl; i++){
        d[i*sl] = i;
      }
      
      //fill up array with scores
      for(i = 1; i<sl; i++){
        d[i] = i;
        if (stop_execution == 1) break;
        current_distance = 10000;
        for(j = 1; j<tl; j++){
          
          cost = 1;
          if(s[i-1] == t[j-1]) cost = 0;
          
          half_sl = (sl - 1)/2;
          half_tl = (tl - 1)/2;
          
          block = block_size < half_sl ? block_size : half_sl;
          block = block < half_tl ? block : half_tl;
          
          while (block >= 1){   
            long swap1 = 1;
            long swap2 = 1;
            i1 = i - (block * 2);
            j1 = j - (block * 2);
            for (k = i1; k < i1 + block; k++) {
              if (s[k] != t[k + block]){
                swap1 = 0;
                break;
              }
            }
            for (k = j1; k < j1 + block; k++) {
              if (t[k] != s[k + block]){
                swap2 = 0;
                break;
              }
            }
            
            del = d[j*sl + i - 1] + 1; 
            ins = d[(j-1)*sl + i] + 1;
            min = del;
            if (ins < min) min = ins;
            //if (i == 2 && j==2) return LONG2NUM(swap2+5); 
            if (i >= block && j >= block && swap1 == 1 && swap2 == 1){
              transp = d[(j - block * 2) * sl + i - block * 2] + cost + block -1; 
              if (transp < min) min = transp;
              block = 0;
            } else if (block == 1) {
              subs = d[(j-1)*sl + i - 1] + cost;
              if (subs < min) min = subs;
            }
            block--;
          } 
          d[j*sl+i]=min;          
          if (current_distance > d[j*sl+i]) current_distance = d[j*sl+i];
        }
        if (current_distance > max_distance) {
          stop_execution = 1;
        }
      }
      distance=d[sl * tl - 1];
      if (stop_execution == 1) distance = current_distance;
      
      free(d);
      return LONG2NUM(distance);
    }
   "
  end
end

if __FILE__ == $0
  a=DamerauLevenshteinMod.new
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
