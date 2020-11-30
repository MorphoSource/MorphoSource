module Morphosource
  class TaxonomySearchService
    include SolrHelper

    attr_reader :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(params={})
      new(params).call
    end

    def initialize(params={})
      @params = params
    end

    def call
      qry = assemble_query
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
  end
end
