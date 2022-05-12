class Morphosource::IDigBioSearchController < ApplicationController

	def search_idigbio_ajax
	  result = search_idigbio(request.params["oid"])
	  respond_to do |wants|
	    wants.json { render json: result }
	    wants.html { render json: result }
	  end
	end

	def search_idigbio(oid)
	  Morphosource::IDigBioSearchService.biological_specimen_params_from_occurrence_id(oid)
	end

end
