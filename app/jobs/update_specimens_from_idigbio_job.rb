class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(specimen_id=nil, save_work=false, system_update=false, force_update=false)
    @specimen_id = specimen_id
    @save_work = save_work
    @system_update = system_update
    @force_update = force_update
    if @specimen_id.present?
      # handle single specimen
      @single_specimen_update = true
    else
      @single_specimen_update = false
    end
    specimen_result.each do |hit|
      params_for_update = Morphosource::IDigBioCompareService.call(hit.id, @force_update)
byebug
      if params_for_update.present?
UpdateSingleSpecimenFromIdigbioJob.perform_now(hit.id, params_for_update)
      end
    end
  end

  def specimen_result
    qry = "has_model_ssim:BiologicalSpecimen"
    if @specimen_id.present?
      qry += " AND id:#{@specimen_id}"
    end
    fields = "id, occurrence_id_tesim, organization_id_tesim, canonical_taxonomy_tesim, taxonomy_id_tesim, idigbio_uuid_tesim, idigbio_recordset_id_tesim, vouchered_tesim, institution_code_tesim, collection_code_tesim, catalog_number_tesim, related_url_tesim, creator_tesim, periodic_time_tesim, original_location_tesim" 
    ActiveFedora::SolrService.query(qry, rows: 999999, fl: fields)
  end

end
