module Morphosource
  class PhysicalObjectParentSearchService
    include SolrHelper
    
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
      query = "#{Solrizer.solr_name('physical_object_id', :stored_searchable)}:#{id} AND has_model_ssim:Media"
      search_solr(query).length
    end

    private

      def find_physical_object_ids(specific_id)
        query = "id:#{prepare_value(specific_id)} AND has_model_ssim:Media"
        result = search_solr(query)&.first
        if result.present? && result[Solrizer.solr_name('physical_object_id', :stored_searchable)].present?
          physical_object_ids.push(*result[Solrizer.solr_name('physical_object_id', :stored_searchable)])
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

      def param_clauses(specific_params)
        clauses = []
        specific_params.each do |k,v|
          clauses << "#{Solrizer.solr_name(k, :symbol)}:#{prepare_value(v)}"
        end
        clauses
      end

      def search_solr(qry)
        ActiveFedora::SolrService.query(qry, rows: 999999, sort: "#{SORTABLE_TITLE_FIELD} ASC", method: :post)
      end
  end
end