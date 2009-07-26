str1 = str2 = block_size = max_distance = distance = dlm = nil

###############
#DAMERAU LEVENSHTEIN MOD
###############

Given /^strings "([^\"]*)" and "([^\"]*)", transposition block size "([^\"]*)", and a maximum allowed distance "([^\"]*)"$/ do |a,b,c,d|
  str1 = a
  str2 = b
  block_size = c.to_i
  max_distance = d.to_i
end

When /^I run "([^\"]*)" instance function "([^\"]*)"$/ do |arg1, arg2|
  dl = eval(arg1 + ".new")
  distance = dl.distance(str1, str2, block_size, max_distance)
end

Then /^I should receive edit distance "([^\"]*)"$/ do |arg1|
  distance.should == arg1.to_i
end

#############
#PARSER
#############

sci_name =  result = nil
parser = Parser.new

Given /^a name "([^\"]*)"$/ do |arg1|
  sci_name = arg1
end

When /^I run a Parser function parse$/ do
  result = parser.parse(sci_name)
end

Then /^I should receive "([^\"]*)" as genus epithet, "([^\"]*)" as species epithet, "([^\"]*)" and "([^\"]*)" as species authors, "([^\"]*)" as a species year$/ do |gen_val, sp_val, au_val1, au_val2, yr_val|
  result[:genus][:epitheton].should == gen_val
  result[:species][:epitheton].should == sp_val
  result[:species][:authors].include?(au_val1).should be_true
  result[:species][:authors].include?(au_val2).should be_true
  result[:species][:years].include?(yr_val).should be_true  
  require 'pp'
  print result
end

#############
# NORMALIZER
#############

string = normalized_string = nil

Given /^a string "([^\"]*)"$/ do |arg1|
  string = arg1
end

When /^I run a Normalizer function normalize$/ do
  normalized_string = Normalizer.normalize(string)
end

Then /^I should receive "([^\"]*)" as a normalized form of the string$/ do |arg1|
  normalized_string.should == arg1
end

######
# PHONETIZER
#####

word = phonetized_word = nil

Given /^a word "([^\"]*)"$/ do |arg1|
  word = arg1
end

When /^I run a Phonetizer function near_match$/ do
  phonetized_word = Phonetizer.near_match(word)
end

Then /^I should receive "([^\"]*)" as a phonetic form of the word$/ do |arg1|
  phonetized_word.should == arg1
end


When /^I run a Phonetizer function near_match with an option normalize_ending$/ do
  phonetized_word = Phonetizer.near_match(word,true)
end

Then /^I should receive "([^\"]*)" as a normalized phonetic form of the word$/ do |arg1|
  phonetized_word.should == arg1
end

