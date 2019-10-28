module Morphosource
  class PhysicalObjectsSearchService

    attr_reader :model, :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(model, params={})
      new(model, params).call
    end

    def initialize(model, params={})
      @model = model
      @params = params
    end

    def call
      qry = assemble_query
      hits = search_solr(qry)
      hits.map { |hit| SolrDocument.new(hit) }
    end

    private

    def assemble_query
      query_clauses = [ model_clause ] + param_clauses
      query_clauses.join(' AND ')
    end

    def model_name
      model.is_a?(Class) ? model.name : model
    end

    def model_clause
      "#{Solrizer.solr_name('has_model', :symbol)}:#{model_name}"
    end

    def param_clauses
      clauses = []
      params.each do |k,v|
        clauses << "#{Solrizer.solr_name(k, :stored_searchable)}:#{v}"
      end
      clauses
    end

    def search_solr(qry)
      ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
    end
  end
end
