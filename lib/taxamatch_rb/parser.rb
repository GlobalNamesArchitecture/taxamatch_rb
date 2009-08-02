# encoding: UTF-8
require 'biodiversity'

class TaxamatchParser
  def initialize
    @parser = ScientificNameParser.new
    @parsed_raw = nil
    @res = {}
  end
  
  def parse(name)
    @res = {:all_authors => [], :all_years => []}
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
    process_node(:species, d['species'], true)
    process_infraspecies(d['infraspecies'])
    @res[:all_authors] = @res[:all_authors].uniq.map {|a| Normalizer.normalize(a)}
    @res[:all_years].uniq!
    @res.keys.size > 2 ? @res : nil
  end
  
  def process_node(name, node, is_species = false)
    return unless node
    @res[name] = {}
    @res[name][:epitheton] = node['epitheton']
    @res[name][:normalized] = Normalizer.normalize(node['epitheton'])
    @res[name][:phonetized] = Phonetizer.near_match(node['epitheton'], is_species)
    get_authors_years(node, @res[name])
  end
  
  def process_infraspecies(node)
    return unless node
    @res[:infraspecies] = []
    node.each do |infr|
      hsh = {}
      hsh[:epitheton] = infr['epitheton']
      hsh[:normalized] = Normalizer.normalize(infr['epitheton'])
      hsh[:phonetized] = Phonetizer.near_match(infr['epitheton'], true)
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
    @res[:all_authors] += res[:authors] if res[:authors].size > 0
    @res[:all_years] += res[:years] if res[:years].size > 0
  end

end

if __FILE__ == $0
  require 'pp'
  p = Parser.new
  puts p.parse('Salmonella werahensis (Castellani) Hauduroy and Ehringer in Hauduroy 1937')  
end