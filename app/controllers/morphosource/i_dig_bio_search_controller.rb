class Morphosource::IDigBioSearchController < ApplicationController

	def search_idigbio_by_occurrence_id_ajax
    if occurrence_id_valid? 
    	result, idb_records = search_idigbio_by_occurrence_id(request.params["oid"])
    else
    	result = {}
    	idb_records = []
    end
	  if result.present? && result["idigbio_uuid"].present?
	  	result.merge!("taxonomy" => taxonomy_param_sets(result["idigbio_uuid"]))
	  end
	  result.merge!("idb_records" => idb_records)
	  respond_to do |wants|
	    wants.json { render json: result }
	    wants.html { render json: result }
	  end
	end

	def search_idigbio_by_occurrence_id(oid)
	  result, idb_records = Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(oid)
		return result, idb_records
	end

	def taxonomy_param_sets(idigbio_uuid)
		result = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_uuid)
	end

  # valid if 8 characters minimum AND has both a letter and a number
	def occurrence_id_valid? 
    occurrence_id = request.params["oid"]
    occurrence_id.present? && occurrence_id.length >= 8 && 
      occurrence_id.count("0-9") > 0 && occurrence_id.count("a-zA-Z") > 0
	end

end
