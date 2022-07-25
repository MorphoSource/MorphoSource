module Morphosource
  class TaxonomySearchService
    include SolrHelper

    attr_reader :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    # Used for finding valid taxonomies based on taxonomic ranks
    TAXONOMIC_RANKS = [
      'taxonomy_kingdom',
      'taxonomy_phylum',
      'taxonomy_class',
      'taxonomy_order',
      'taxonomy_family',
      'taxonomy_genus',
      'taxonomy_species'
    ]

    def self.call(params={})
      new(params).call
    end

    # Find taxonomies that match taxonomic rank values occurring to specific rules
    def self.find_valid_taxonomies(taxonomic_rank_params={})
      new(
        taxonomic_rank_params.slice(*TAXONOMIC_RANKS).select { |k, v| v.present? }
      ).find_valid_taxonomies
    end


    def initialize(params={})
      @params = params
    end

    def call
      return [] unless params.present?
      qry = assemble_query
      hits = search_solr(qry)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    def find_valid_taxonomies
      return [] unless params.present?
      qry = assemble_strict_taxonomy_query
      hits = search_solr(qry)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    private

      def model_clause
        "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy"
      end

      def search_solr(qry)
        ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC", method: :post)
      end

      def assemble_strict_taxonomy_query
        if params['taxonomy_genus'].present? && params['taxonomy_species'].present? 
          query_clauses = [ model_clause ] + param_clauses
        else
          query_clauses = [ model_clause ] + assemble_strict_query_higher_taxonomy
        end
        query_clauses.join(' AND ')
      end

      def assemble_strict_query_higher_taxonomy
        positive_clauses = params.map { |k,v| "#{Solrizer.solr_name(k, :stored_searchable)}:#{prepare_value(v)}" }
        negative_clauses = (TAXONOMIC_RANKS - params.keys).map { |k| "-#{Solrizer.solr_name(k, :stored_searchable)}:*" }
        positive_clauses + negative_clauses
      end
  end
end
