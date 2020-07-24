module Morphosource
	module Collections
		class CollectionFilterService
		
			attr_reader :collection_id, :solr, :facet_results

	    SORTABLE_TITLE_FIELD = Solrizer.solr_name('title', :stored_sortable)

	    def self.call(collection_id)
	      new(collection_id).call
	    end

	    def initialize(collection_id)
	    	@solr = solr_service.new
	      @collection_id = collection_id
	    end

	    def call
	      collection_media_solr_query
	    end

	    def collection_media_solr_query
	    	query = "#{solrize('member_of_collection_ids', :symbol)}:#{collection_id}"
	    	facet_fields = [
	    		solrize('media_type', :stored_searchable),
	    		solrize('fileset_accessibility', :stored_searchable),
	    		solrize('physical_object_id', :stored_searchable),
	    		solrize('member_of_collection_ids', :symbol)
	    	]
	    	addl_params = { rows: 0 }

	    	solr.get_facet_fields(query, facet_fields, addl_params)

	    	@facet_results = solr.facet_fields(facet_fields)
	    end

	    private

	    def map_media_type(t)
	    	case t
	    	when 'ctimagesery' then 'CTImageSeries'
	    	when 'photogrammetryimagesery' then 'PhotogrammetryImageSeries'
	    	else t.titleize
	    	end
	    end

	    def solr_service
	    	Morphosource::SolrService
	    end

	    def solrize(name, type)
	    	Solrizer.solr_name(name, type)
	    end

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
	        term_type = ( k == 'member_ids' ? :symbol : :stored_searchable )
	        clauses << "#{Solrizer.solr_name(k, term_type)}:#{prepare_value(v)}"
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
end