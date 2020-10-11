module Morphosource
	class TaxonomyBrowseService
    attr_reader :names, :absent_ranks, :solr

    TAXONOMY_RANKS = [
      'kingdom',
      'phylum',
      'class',
      'order',
      'family',
      'genus'
    ]

    # names should be an array of hashes with name and rank information
    # e.g., [{name: 'Animalia', rank: 'kingdom'}, {name: 'Chordata', rank: 'phylum'}]
    def self.call(names=[], absent_ranks=[])
      new(names, absent_ranks).call
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

    
    def all_children(names, absent_ranks=[])
      subrank = get_subrank(absent_ranks.present? ? absent_ranks.last : names.last[:rank])
      return nil if !subrank

      children = {}

      immediate_children = direct_children(names, absent_ranks)
      children[subrank] = immediate_children if immediate_children.present?

      # are there distant children to be gathered?
      if count_nameless_children(names, absent_ranks) > 0
        puts('Nameless children!')
        children.merge!(all_children(names, absent_ranks + [subrank]))
      end

      return children
    end

    # For a set of names, returns direct children with non-"" names
    def direct_children(names=[], absent_ranks=[])
      return nil if !names.present?

      solr_params = {
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      names.each do |n|
         return nil if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
         solr_params[:fq] << "#{prepare_field(n[:rank])}:#{n[:name]}"
      end

      absent_ranks.each do |r|
        return nil if !r.present? || !TAXONOMY_RANKS.include?(r)
        solr_params[:fq] << "!#{prepare_field(r)}:*"
      end

      subrank = get_subrank(absent_ranks.present? ? absent_ranks.last : names.last[:rank])
      return nil if !subrank

      solr_params[:fl] = prepare_field(subrank)

      solr.get_docs(nil, solr_params).map(&:values).flatten.uniq
    end

    # For a set of names, returns count of direct children with "" names
    def count_nameless_children(names=[], absent_ranks=[])
      return nil if !names.present?

      solr_params = {
        fl: 'id',
        fq: [
          "#{solrize('has_model', :symbol)}:Taxonomy",
          "#{solrize('gbif_key', :stored_searchable)}:*"
        ]
      }

      names.each do |n|
         return nil if !n[:name].present? || !n[:rank].present? || !TAXONOMY_RANKS.include?(n[:rank])
         solr_params[:fq] << "#{prepare_field(n[:rank])}:#{n[:name]}"
      end

      absent_ranks.each do |r|
        return nil if !r.present? || !TAXONOMY_RANKS.include?(r)
        solr_params[:fq] << "!#{prepare_field(r)}:*"
      end

      subrank = get_subrank(absent_ranks.present? ? absent_ranks.last : names.last[:rank])
      return nil if !subrank
      solr_params[:fq] << "!#{prepare_field(subrank)}:*"

      solr.get_count(nil, solr_params)
    end

    def get_subrank(rank, nth=1)
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

  end
end