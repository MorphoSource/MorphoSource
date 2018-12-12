module Morphosource
  class PhysicalObjectsSearchService

    attr_reader :institution_code, :model, :params

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(model, params={})
      new(model, params).call
    end

    def initialize(model, params={})
      @model = model
      @institution_code = params.delete('institution_code')
      @params = params
    end

    def call
      qry = assemble_query
      hits = search_solr(qry)
      hits = filter_on_institution(hits) if institution_code.present?
      hits.map { |hit| SolrDocument.new(hit) }
    end

    private

    def assemble_query
      query_clauses = [ model_clause ] + param_clauses
      query_clauses.join(' AND ')
    end

    def filter_on_institution(hits)
      inst_doc = institution_doc
      inst_member_ids = inst_doc[Solrizer.solr_name('member_ids', :symbol)]
      hits.select { |hit| inst_member_ids.include?(hit.id) }
    end

    def institution_doc
      inst_qry_clauses = [ "#{Solrizer.solr_name('has_model', :symbol)}:Institution",
                           "#{Solrizer.solr_name('institution_code', :stored_searchable)}:#{institution_code}" ]
      inst_qry = inst_qry_clauses.join(' AND ')
      SolrDocument.new(ActiveFedora::SolrService.query(inst_qry, rows: 999999).first)
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
