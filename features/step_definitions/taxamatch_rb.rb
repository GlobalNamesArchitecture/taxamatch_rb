str1 = str2 = block_size = max_distance = distance = dlm = nil

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

sci_name = parser = result = nil

Given /^a name "([^\"]*)"$/ do |arg1|
  sci_name = arg1
end

When /^I run a parser from biodiversity gem$/ do
  parser = Parser.new
end

Then /^I should receive "([^\"]*)" as genus epithet, "([^\"]*)" as species epithet, "([^\"]*)" and "([^\"]*)" as species authors, "([^\"]*)" as a species year$/ do |gen_val, sp_val, au_val1, au_val2, yr_val|
  res = parser.parse(sci_name)
  res[:genus][:epitheton].should == gen_val
  res[:species][:epitheton].should == sp_val
  res[:species][:authors].include?(au_val1).should be_true
  res[:species][:authors].include?(au_val2).should be_true
  res[:species][:years].include?(yr_val).should be_true  
end
