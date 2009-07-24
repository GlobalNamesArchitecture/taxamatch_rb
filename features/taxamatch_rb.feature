Feature: Find if two scientific names are lexical variants of each other

  As a Biodiversity Informatician
  I want to be able to compare scientific names to determine if they are variants of the same name.
  And I want to be able to combine names that are the same into lexical groups, so they appear together in names list
  So I want to implement Tony Rees and Barbara Boehmer taxamatch algorithms http://bit.ly/boWyG in ruby, my language of choice.


  Scenario: find edit distance between two unicode (utf8) strings
    Given strings "Sjostedt" and "Sojstedt", transposition block size "1", and a maximum allowed distance "4"
    When I run "DamerauLevenshteinMod" instance function "distance"
    Then I should receive edit distance "1"

  Scenario: find parts of a name in unicode
    Given a name "Arthopyrenia hyalospora (Banker) D. Hall 1988"
    When I run a parser from biodiversity gem
    Then I should receive "ARTHOPYRENIA" as "genus_epitheton", "HYALOSPORA" as "species_epitheton", "Banker" and "D. Hall" as "authors", "1988" as a "year"

