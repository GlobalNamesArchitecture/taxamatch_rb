# encoding: UTF-8
require 'biodiversity'

module Taxamatch

  class Atomizer
    def initialize
      @parser = ScientificNameParser.new
      @parsed_raw = nil
      @res = {}
    end
  
    def parse(name)
      @res = {:all_authors => [], :all_years => []}
      @parsed_raw = @parser.parse(name)[:scientificName]
      organize_results
    end
  
    def parsed_raw
      return @parsed_raw
    end

  protected

    def organize_results
      pr = @parsed_raw
      return nil unless pr[:parsed]
      d = pr[:details][0]
      process_node(:uninomial, d[:uninomial])
      process_node(:genus, d[:genus])
      process_node(:species, d[:species], true)
      process_infraspecies(d[:infraspecies])
      @res[:all_authors] = @res[:all_authors].uniq.map {|a| Taxamatch::Normalizer.normalize(a)}
      @res[:all_years].uniq!
      @res.keys.size > 2 ? @res : nil
    end
  
    def process_node(name, node, is_species = false)
      return unless node
      @res[name] = {}
      @res[name][:string] = node[:string]
      @res[name][:normalized] = Taxamatch::Normalizer.normalize(node[:string])
      @res[name][:phonetized] = Taxamatch::Phonetizer.near_match(node[:string], is_species)
      get_authors_years(node, @res[name])
    end
  
    def process_infraspecies(node)
      return unless node
      @res[:infraspecies] = []
      node.each do |infr|
        hsh = {}
        hsh[:string] = infr[:string]
        hsh[:normalized] = Taxamatch::Normalizer.normalize(infr[:string])
        hsh[:phonetized] = Taxamatch::Phonetizer.near_match(infr[:string], true)
        get_authors_years(infr,hsh)
        @res[:infraspecies] << hsh
      end
    end
  
    def get_authors_years(node, res)
      res[:authors] = []
      res[:years] = []
      [:basionymAuthorTeam, :combinationAuthorTeam].each do |au|
        if node[au]
          res[:authors] += node[au][:author] 
          res[:years] << node[au][:year] if node[au][:year]
          if node[au][:exAuthorTeam]
            res[:authors] += node[au][:exAuthorTeam][:author]
            res[:years] << node[au][:exAuthorTeam][:year] if node[au][:exAuthorTeam][:year]
          end
        end
      end
      res[:authors].uniq!
      res[:normalized_authors] = res[:authors].map {|a| Taxamatch::Normalizer.normalize_author(a)}
      res[:years].uniq!
      @res[:all_authors] += res[:normalized_authors] if res[:normalized_authors].size > 0
      @res[:all_years] += res[:years] if res[:years].size > 0
    end

  end
end

