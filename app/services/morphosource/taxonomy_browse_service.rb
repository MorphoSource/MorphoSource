module Morphosource
	class TaxonomyBrowseService
    include SolrHelper

    attr_reader :names, :absent_ranks, :solr

    TAXONOMY_RANKS = [
      'kingdom',
      'phylum',
      'class',
      'order',
      'family',
      'genus',
      'species'
    ]

    # names should be an array of hashes with name and rank information
    # e.g., [{name: 'Animalia', rank: 'kingdom'}, {name: 'Chordata', rank: 'phylum'}]
    # If names is empty, will return kingdoms!
    def self.call(names=[], absent_ranks=[])
      new(names, absent_ranks).call
    end

    def self.count(names=[], absent_ranks=[])
      new(names, absent_ranks).count
    end

    def self.taxonomy_specimens(taxonomies = [])
      new.taxonomy_specimens(taxonomies)
    end

    def self.taxonomy_specimens_count(taxonomies = [])
      new.taxonomy_specimens_count(taxonomies)
    end

    def initialize(names=[], absent_ranks=[])
      @names = names
      @absent_ranks = absent_ranks
      @solr = solr_service.new
    end

    # 
    def call
      all_children(names, absent_ranks)
    end

    def count
      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      names.each do |n|
         return nil if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
         solr_params[:fq] << "#{prepare_field(n[:rank])}:#{prepare_value(n[:name])}"
      end

      absent_ranks.each do |r|
        return nil if !r.present? || !TAXONOMY_RANKS.include?(r)
        solr_params[:fq] << "!#{prepare_field(r)}:*"
      end

      solr.get_count(nil, solr_params)
    end

    
    def all_children(names=[], absent_ranks=[])
      subrank = get_subrank(names, absent_ranks)
      return nil if !subrank

      children = {}

      immediate_children = direct_children(names, absent_ranks)
      children[subrank] = immediate_children if immediate_children.present?

      # are there distant children to be gathered? don't do this when looking for species
      if subrank != 'species' && count_nameless_children(names, absent_ranks) > 0
        puts('Nameless children!')
        children.merge!(all_children(names, absent_ranks + [subrank]))
      end

      return children
    end

    # For a set of names, returns direct children with non-"" names
    def direct_children(names=[], absent_ranks=[])
      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      names.each do |n|
         return nil if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
         solr_params[:fq] << "#{prepare_field(n[:rank])}:#{prepare_value(n[:name])}"
      end

      absent_ranks.each do |r|
        return nil if !r.present? || !TAXONOMY_RANKS.include?(r)
        solr_params[:fq] << "!#{prepare_field(r)}:*"
      end

      subrank = get_subrank(names, absent_ranks)
      return nil if !subrank

      solr_params[:fl] = prepare_field(subrank)

      solr.get_docs(nil, solr_params)
        .map(&:values)
        .flatten
        .each_with_object(Hash.new(0)) { |o, h| h[o] += 1 } # count name appearances
        .sort.to_h # sort alphabetically by key
        .each_with_object({}) do |(k, v), a| 
          if subrank == 'species' and (genus = names.find { |n| n[:rank] == 'genus' } ).present?
            count_names = [ { name: k, rank: subrank }, genus ]
          else
            count_names = [name: k, rank: subrank]
          end
          a[k] = { count: v, specimen_count: taxonomy_specimens_count(count_names) } # count specimen numbers
        end
    end

    # For a set of names, returns count of direct children with "" names
    def count_nameless_children(names=[], absent_ranks=[])
      solr_params = {
        fl: 'id',
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      names.each do |n|
         return nil if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
         solr_params[:fq] << "#{prepare_field(n[:rank])}:#{prepare_value(n[:name])}"
      end

      absent_ranks.each do |r|
        return nil if !r.present? || !TAXONOMY_RANKS.include?(r)
        solr_params[:fq] << "!#{prepare_field(r)}:*"
      end

      subrank = get_subrank(names, absent_ranks)
      return nil if !subrank
      solr_params[:fq] << "!#{prepare_field(subrank)}:*"

      solr.get_count(nil, solr_params)
    end

    def get_subrank(names=[], absent_ranks=[])
      if absent_ranks.present?
        rank = absent_ranks.last
      elsif names.present? 
        rank = names.last[:rank]
      else
        return TAXONOMY_RANKS.first
      end

      idx = TAXONOMY_RANKS.index(rank)
      TAXONOMY_RANKS[idx+1] if idx
    end

    def prepare_field(val)
      solrize("taxonomy_#{val}", :stored_searchable)
    end

    ### Solr utility methods ###

    def solr_service
      Morphosource::SolrService
    end

    def solrize(name, type)
      Solrizer.solr_name(name, type)
    end

    # Get specimens with published media for GBIF taxonomy rank
    def taxonomy_specimens(taxonomies = [])
      taxonomy_specimen_query(taxonomies.map { |t| t[:name] })['response']
    end

    def taxonomy_specimens_count(taxonomies = [])
      taxonomy_specimen_query(taxonomies.map { |t| t[:name] })['response']['numFound'].to_i
    end

    def taxonomy_specimen_query(names = [])
      solr_params = {
        fl: ['id', 'title_tesim', 'taxonomy_tesim', 'taxonomy_id_tesim'],
        fq: [
          "#{solrize('has_model', :symbol)}:BiologicalSpecimen",
          "#{solrize('external_taxonomy', :symbol)}:*",
          "#{solrize('public_media_type', :stored_searchable)}:*",
        ],
        rows: 100
      }

      names.each do |n|
        next unless n.present?
        solr_params[:fq] << "#{solrize('external_taxonomy', :symbol)}:#{prepare_value(n)}"
      end

      solr.get(nil, solr_params)
    end

    def all_taxonomy_ids_for_rank(taxonomies)
      return [] if !taxonomies.present?
      solr_params = {
        fl: ['id'],
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      taxonomies.each do |n|
        return [] if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
        solr_params[:fq] << "#{prepare_field(n[:rank])}:#{prepare_value(n[:name])}"
      end

      solr.get_docs(nil, solr_params).map { |x| x['id'] }
    end
  end
end