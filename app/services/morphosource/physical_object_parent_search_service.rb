module Morphosource
  class PhysicalObjectParentSearchService
    # On one vagrant test, across 68 media this took on average 15 - 20 ms per media to find the biological objects

    attr_reader :params, :id, :physical_object_ids

    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

    def self.call(params={})
      new(params).call
    end

    def self.total_media_count(physical_object_id)
      new( { id: physical_object_id } ).total_media_count_for_po
    end

    def initialize(params={})
      @params = params
      @id = params[:id]
      @physical_object_ids = []
    end

    def call
      find_physical_object_ids(id)
      find_physical_objects
    end

    def total_media_count_for_po
      query = "#{Solrizer.solr_name('physical_object_id', :stored_searchable)}:#{id}"
      search_solr(query).length
    end

    private

    def find_physical_object_ids(specific_id)
      parents = find_parents(specific_id)
      parents.each do |p|
        if p['has_model_ssim']&.first == 'BiologicalSpecimen' || p['has_model_ssim']&.first == 'CulturalHeritageObject'
          physical_object_ids << p['id']
        else
          find_physical_object_ids(p['id'])
        end
      end
    end

    def find_parents(specific_id)
      qry = assemble_query({ 'member_ids' => specific_id })
      search_solr(qry)
    end

    def find_physical_objects
      physical_object_ids.map do |po_id|
        qry = "id:#{po_id}"
        SolrDocument.new(search_solr(qry).first)
      end
    end

    def assemble_query(specific_params)
      query_clauses = param_clauses(specific_params)
      query_clauses.join(' AND ')
    end

    def model_clause
      "#{Solrizer.solr_name('has_model', :symbol)}:ProcessingEvent"
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