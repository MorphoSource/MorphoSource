module Morphosource
  class RequestsSearchService

    attr_reader :params, :id, :physical_object_ids

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(params={})
      new(params).call
    end

    def initialize(params={})
      @params = params
      @ms_id = params[:ms_id]
    end

    def call
      find_media(@ms_id)
    end

    private

    def find_media(ms_id)
      qry = assemble_query({ 'depositor' => ms_id, 'owner' => ms_id, 'download_reviewer' => ms_id })
      search_solr(qry)
    end

    def assemble_query(specific_params)
      query_clauses = param_clauses(specific_params)
      query_clauses.join(' OR ')
    end

    def model_clause
      "#{Solrizer.solr_name('has_model', :symbol)}:Media"
    end

    def param_clauses(specific_params)
      clauses = []
      specific_params.each do |k,v|
        clauses << "#{Solrizer.solr_name(k, :symbol)}:#{prepare_value(v)}"
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
