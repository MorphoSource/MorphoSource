module Morphosource
  class TaxonomySearchService

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

    def assemble_query
      query_clauses = [ model_clause ] + param_clauses
      query_clauses.join(' AND ')
    end

    def model_clause
      "#{Solrizer.solr_name('has_model', :symbol)}:Taxonomy"
    end

    def param_clauses
      clauses = []
      params.each do |k,v|
        clauses << "#{Solrizer.solr_name(k, :stored_searchable)}:#{prepare_value(v)}"
      end
      clauses
    end

    def prepare_value(v)
      if v.to_s.include? " "
        "\"#{v}\"" 
      else
        v
      end
    end

    def search_solr(qry)
      ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC")
    end
  end
end
