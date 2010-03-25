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
parser = Taxamatch::Atomizer.new

Given /^a name "([^\"]*)"$/ do |arg1|
  sci_name = arg1
end

When /^I run a Taxamatch::Atomizer function parse$/ do
  result = parser.parse(sci_name)
end

Then /^I should receive "([^\"]*)" as genus epithet, "([^\"]*)" as species epithet, "([^\"]*)" and "([^\"]*)" as species authors, "([^\"]*)" as a species year$/ do |gen_val, sp_val, au_val1, au_val2, yr_val|
  result[:genus][:string].should == gen_val
  result[:species][:string].should == sp_val
  result[:species][:authors].include?(au_val1).should be_true
  result[:species][:authors].include?(au_val2).should be_true
  result[:species][:years].include?(yr_val).should be_true  
end

#############
# NORMALIZER
#############

string = normalized_string = nil

Given /^a string "([^\"]*)"$/ do |arg1|
  string = arg1
end

When /^I run a Taxamatch::Normalizer function normalize$/ do
  normalized_string = Taxamatch::Normalizer.normalize(string)
end

Then /^I should receive "([^\"]*)" as a normalized form of the string$/ do |arg1|
  puts Taxamatch::Normalizer.normalize(string)
  normalized_string.should == arg1
end

######
# PHONETIZER
#####

word = phonetized_word = nil

Given /^a word "([^\"]*)"$/ do |arg1|
  word = arg1
end

When /^I run a Taxamatch::Phonetizer function near_match$/ do
  phonetized_word = Taxamatch::Phonetizer.near_match(word)
end

Then /^I should receive "([^\"]*)" as a phonetic form of the word$/ do |arg1|
  phonetized_word.should == arg1
end


When /^I run a Taxamatch::Phonetizer function near_match with an option normalize_ending$/ do
  phonetized_word = Taxamatch::Phonetizer.near_match(word,true)
end

Then /^I should receive "([^\"]*)" as a normalized phonetic form of the word$/ do |arg1|
  phonetized_word.should == arg1
end

name1 = name2 = match = nil
tm = Taxamatch::Base.new

Given /^strings "([^\"]*)" and "([^\"]*)"$/ do |arg1, arg2|
  name1 = arg1
  name2 = arg2
end

When /^I run taxmatch method of Taxamatch class$/ do
  match = tm.taxamatch(name1, name2)
end

Then /^I should see that these two names match$/ do
  match.should be_true
end

auth1 = auth2 = yr1 = yr2 = match = nil
au=Taxamatch::Authmatch

Given /^authors "([^\"]*)","([^\"]*)" with year "([^\"]*)" and authors "([^\"]*)" and year "([^\"]*)"$/ do |arg1, arg2, arg3, arg4, arg5|
  auth1 = [arg1,arg2]
  yr1 = [arg3]
  auth2 = [arg4]
  yr2 = [arg5]
end

When /^I ran Authormatch method compare_authorship$/ do
  match = au.authmatch(auth1, auth2, yr1, yr2)
end

Then /^I should see that there is a match$/ do
  match.should == 0
end

