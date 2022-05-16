class Morphosource::IDigBioSearchController < ApplicationController

	def search_idigbio_by_occurrence_id_ajax
	  result = search_idigbio_by_occurrence_id(request.params["oid"])
	  if result.present? && result["idigbio_uuid"].present?
	  	result.merge!("taxonomy_param_sets" => taxonomy_param_sets(result["idigbio_uuid"]))
	  end
	  respond_to do |wants|
	    wants.json { render json: result }
	    wants.html { render json: result }
	  end
	end

	def search_idigbio_by_occurrence_id(oid)
	  result = Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(oid)
	end

	def taxonomy_param_sets(idigbio_uuid)
		result = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_uuid)
	end

end
