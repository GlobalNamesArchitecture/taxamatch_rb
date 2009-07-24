require 'biodiversity'
require 'unicode_utils/upcase'

class Parser
  def initialize
    @parser = ScientificNameParser.new
  end
  
  def parse(name)
    res = @parser.parse(name)
  end

end