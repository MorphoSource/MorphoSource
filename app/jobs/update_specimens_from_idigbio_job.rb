class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(save_work=false, force_update=false)
    @save_work = save_work
    @force_update = force_update
    specimen_result.each do |hit|      
      if (params_for_update = Morphosource::IDigBioCompareService.call(hit.id, @force_update)).present?
byebug
# later
        UpdateSingleSpecimenFromIdigbioJob.perform_now(hit.id, system_update=true, params_for_update)
      end
    end
  end

  def specimen_result
    qry = "has_model_ssim:BiologicalSpecimen"
    fields = "id, occurrence_id_tesim, organization_id_tesim, canonical_taxonomy_tesim, taxonomy_id_tesim, idigbio_uuid_tesim, idigbio_recordset_id_tesim, vouchered_tesim, institution_code_tesim, collection_code_tesim, catalog_number_tesim, related_url_tesim, creator_tesim, periodic_time_tesim, original_location_tesim" 
    ActiveFedora::SolrService.query(qry, rows: 999999, fl: fields)
  end

end
