# encoding: UTF-8
require 'biodiversity'

class Parser
  def initialize
    @parser = ScientificNameParser.new
    @parsed_raw = nil
    @res = {}
  end
  
  def parse(name)
    @res = {}
    @parsed_raw = JSON.load(@parser.parse(name).to_json)['scientificName']
    organize_results
  end
  
  def parsed_raw
    return @parsed_raw
  end

protected

  def organize_results
    pr = @parsed_raw
    return nil unless pr['parsed']
    d = pr['details'][0]
    process_node(:uninomial, d['uninomial'])
    process_node(:genus, d['genus'])
    process_node(:species, d['species'])
    process_infraspecies(d['infraspecies'])
    @res.keys.size >= 0 ? @res : nil
  end
  
  def process_node(name,node)
    return unless node
    @res[name] = {}
    @res[name][:epitheton] = Normalizer.normalize(node['epitheton'])
    get_authors_years(node, @res[name])
  end
  
  def process_infraspecies(node)
    return unless node
    @res[:infraspecies] = []
    node.each do |infr|
      hsh = {}
      hsh[:epitheton] = Normalizer.normalize(infr['epitheton'])
      get_authors_years(infr,hsh)
      @res[:infraspecies] << hsh
    end
  end
  
  def get_authors_years(node, res)
    res[:authors] = []
    res[:years] = []
    ['basionymAuthorTeam','combinationAuthorTeam'].each do |au|
      if node[au]
        res[:authors] += node[au]['author'] 
        res[:years] << node[au]['year'] if node[au]['year']
        if node[au]['exAuthorTeam']
          res[:authors] += node[au]['exAuthorTeam']['author']
          res[:years] << node[au]['exAuthorTeam']['year'] if node[au]['exAuthorTeam']['year']
        end
      end
    end
    res[:authors].uniq!
    res[:years].uniq!
  end

end

if __FILE__ == $0
  require 'pp'
  p = Parser.new
  puts p.parse('Salmonella werahensis (Castellani) Hauduroy and Ehringer in Hauduroy 1937')  
end