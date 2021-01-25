module Morphosource
  class PhysicalObjectsSearchService
    include SolrHelper

    attr_reader :solr, :taxonomy_genus, :taxonomy_species, :model, :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(model, params={})
      new(model, params).call
    end

    def initialize(model, params={})
      @solr = solr_service.new
      @model = model
      @taxonomy_genus = params.delete('taxonomy_genus')
      @taxonomy_species = params.delete('taxonomy_species')
      @params = params
    end

    def call
      qry = assemble_query
      hits = solr.get_docs(qry)
      hits = filter_on_taxonomy(hits) if (taxonomy_genus.present? || taxonomy_species.present?)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    def taxonomy_docs
      taxonomy_query_clauses = [ "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy" ]
      taxonomy_query_clauses << "#{Solrizer.solr_name('taxonomy_genus', :stored_searchable)}:(#{prepare_value(taxonomy_genus)})" if taxonomy_genus.present?
      taxonomy_query_clauses << "#{Solrizer.solr_name('taxonomy_species', :stored_searchable)}:(#{prepare_value(taxonomy_species)})" if taxonomy_species.present?
      taxonomy_query = taxonomy_query_clauses.join(' AND ')
      solr.get_docs(taxonomy_query)
    end

    private

      def filter_on_taxonomy(hits)
        taxonomy_ids = taxonomy_docs.map { |d| d['id'] }
        if taxonomy_ids.present?
          hits.select { |hit| (hit[solrize('taxonomy_id', :stored_searchable)] & taxonomy_ids).present? }
        else
          []
        end
      end

      def model_name
        model.is_a?(Class) ? model.name : model
      end

      def model_clause
        "#{Solrizer.solr_name('has_model', :symbol)}:#{model_name}"
      end
  end
end
