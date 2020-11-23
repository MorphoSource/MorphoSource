module Morphosource
  class PhysicalObjectsSearchService
    include SolrHelper

    attr_reader :taxonomy_genus, :taxonomy_species, :model, :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(model, params={})
      new(model, params).call
    end

    def initialize(model, params={})
      @model = model
      @taxonomy_genus = params.delete('taxonomy_genus')
      @taxonomy_species = params.delete('taxonomy_species')
      @params = params
    end

    def call
      qry = assemble_query
      hits = search_solr(qry)
      hits = filter_on_taxonomy(hits) if (taxonomy_genus.present? || taxonomy_species.present?)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    def taxonomy_doc
      taxonomy_query_clauses = [ "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy" ]
      taxonomy_query_clauses << "#{Solrizer.solr_name('taxonomy_genus', :stored_searchable)}:(#{taxonomy_genus})" if taxonomy_genus.present?
      taxonomy_query_clauses << "#{Solrizer.solr_name('taxonomy_species', :stored_searchable)}:(#{taxonomy_species})" if taxonomy_species.present?
      taxonomy_query = taxonomy_query_clauses.join(' AND ')
      SolrDocument.new(ActiveFedora::SolrService.query(taxonomy_query, rows: 999999).first)
    end

    private

      def filter_on_taxonomy(hits)
        tax_doc = taxonomy_doc
        taxonomy_member_ids = tax_doc[Solrizer.solr_name('member_ids', :symbol)]
        if taxonomy_member_ids.present?
          hits.select { |hit| taxonomy_member_ids.include?(hit.id) }
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

      def search_solr(qry)
        ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC", method: :post)
      end
  end
end
