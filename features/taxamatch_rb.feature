Feature: Find if two scientific names are lexical variants of each other

  As a Biodiversity Informatician
  I want to be able to compare scientific names to determine if they are variants of the same name.
  And I want to be able to combine names that are the same into lexical groups, so they appear together in names list
  So I want to implement Tony Rees and Barbara Boehmer taxamatch algorithms http://bit.ly/boWyG
  
  Scenario: compare two scientific names if they match
    Given strings "Betula verucosa L." and "Betula vericosa Linn."
    When I run taxmatch method of Taxamatch class
    Then I should see that these two names match
    
  Scenario: compare two authorships
    Given authors "Linneaus","Muller" with year "1789" and authors "Linnaeus" and year "1780"
    When I ran Authormatch method compare_authorship
    Then I should see that there is a match
    

  Scenario: find edit distance between two unicode (utf8) strings
    Given strings "Sjostedt" and "Sojstedt", transposition block size "1", and a maximum allowed distance "4"
    When I run "DamerauLevenshteinMod" instance function "distance"
    Then I should receive edit distance "1"

  Scenario: find parts of a name in unicode
    Given a name "Arthopyrenia hyalospora (Banker) D. Hall 1988 hyalosporis Kutz 1999"
    When I run a TaxamatchParser function parse
    Then I should receive "Arthopyrenia" as genus epithet, "hyalospora" as species epithet, "Banker" and "D. Hall" as species authors, "1988" as a species year
    
  Scenario: normalize a string into ASCII upcase
    Given a string "Choriozopella trägårdhi"
    When I run a Normalizer function normalize
    Then I should receive "CHORIOZOPELLA TRAGARDHI" as a normalized form of the string
    
  Scenario: create phonetic version of a word
    Given a word "bifasciata"
    When I run a Phonetizer function near_match
    Then I should receive "BIFASATA" as a phonetic form of the word
  
  Scenario: create phonetic version of a species epithet normalizing ending
    Given a word "bifasciatum"
    When I run a Phonetizer function near_match with an option normalize_ending
    Then I should receive "BIFASATA" as a normalized phonetic form of the word
