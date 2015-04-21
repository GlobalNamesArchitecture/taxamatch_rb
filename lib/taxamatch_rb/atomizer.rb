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
      @parsed_raw = @parser.parse(name)[:scientificName]
      organize_results(@parsed_raw)
    end

    def parsed_raw
      return @parsed_raw
    end

    def organize_results(parsed_raw)
      pr = parsed_raw
      return nil unless pr[:parsed]
      @res = {:all_authors => [], :all_years => []}
      d = pr[:details][0]
      @res[:canonical_form] = pr[:canonical]
      process_node(:uninomial, d[:uninomial])
      process_node(:genus, d[:genus])
      process_node(:species, d[:species], true)
      process_infraspecies(d[:infraspecies])
      @res[:all_authors] = @res[:all_authors].uniq.map do |a|
        Taxamatch::Normalizer.normalize(a)
      end
      @res[:all_years].uniq!
      @res.keys.size > 2 ? @res : nil
    end

    private

    def process_node(name, node, is_species = false)
      return unless node && node[:string]
      @res[name] = {}
      @res[name][:string] = node[:string]
      @res[name][:normalized] = Taxamatch::Normalizer.normalize(node[:string])
      @res[name][:phonetized] =
        Taxamatch::Phonetizer.near_match(node[:string], is_species)
      get_authors_years(node, @res[name])
    end

    def process_infraspecies(node)
      return unless node
      @res[:infraspecies] = []
      node.each do |infr|
        next unless infr[:string]
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
          if node[au][:year]
            year = Taxamatch::Normalizer.normalize_year(node[au][:year])
            res[:years] << year if year
          end
          if node[au][:exAuthorTeam]
            res[:authors] += node[au][:exAuthorTeam][:author]
            if node[au][:exAuthorTeam][:year]
              year = node[au][:exAuthorTeam][:year]
              year = Taxamatch::Normalizer.normalize_year(year)
              res[:years] << year if year
            end
          end
        end
      end
      res[:authors].uniq!
      res[:normalized_authors] = res[:authors].map do |a|
        Taxamatch::Normalizer.normalize_author(a)
      end
      res[:years].uniq!
      if res[:normalized_authors].size > 0
        @res[:all_authors] += res[:normalized_authors]
      end
      @res[:all_years] += res[:years] if res[:years].size > 0
    end

  end
end

