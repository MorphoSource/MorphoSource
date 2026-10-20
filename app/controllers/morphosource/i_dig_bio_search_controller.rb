class Morphosource::IDigBioSearchController < ApplicationController

  # Looks up the best remote record for a changed occurrence ID on the specimen edit page.
  def search_idigbio_by_occurrence_id_ajax
    result = Morphosource::SpecimenSources::Resolver
      .new(organization_id: request.params["organization_id"])
      .find_by_occurrence_id(request.params["oid"])

    response = { "status" => result.status.to_s, "candidate_count" => result.candidates.length }
    if result.found?
      record = result.record
      response.merge!(record.specimen_params)
      response.merge!(
        "source" => record.source_key.to_s,
        "source_label" => record.source_label,
        "record_id" => record.id,
        "record_url" => record.url,
        "taxonomy" => record.taxonomy_param_sets
      )
    end

    respond_to do |wants|
      wants.json { render json: response }
      wants.html { render json: response }
    end
  end

end
