class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(bso_id=nil, save_work=false, system_update=false, force_update=false)
    @bso_id = bso_id
    @save_work = save_work
    @system_update = system_update
    @force_update = force_update
    if @bso_id.present?
      # handle single specimen
      @single_specimen_update = true
    else
      @single_specimen_update = false
    end
    bso_result.each do |hit|
      idb_compare_object = Morphosource::IDigBioCompareService.call(hit.id, @force_update)

byebug
      if idb_compare_object[:ok_to_update] == true 
#        UpdateSingleSpecimenFromIdigbioJob.perform_later(hit.id, idb_compare_object[:params_for_update])
UpdateSingleSpecimenFromIdigbioJob.perform_now(hit.id, idb_compare_object[:params_for_update])
      end
    end
  end

  def bso_result
    qry = "has_model_ssim:BiologicalSpecimen"
    if @bso_id.present?
      qry += " AND id:#{@bso_id}"
    end
    fields = "id, occurrence_id_tesim, organization_id_tesim, canonical_taxonomy_tesim, taxonomy_id_tesim, idigbio_uuid_tesim, idigbio_recordset_id_tesim, vouchered_tesim, institution_code_tesim, collection_code_tesim, catalog_number_tesim, related_url_tesim, creator_tesim, periodic_time_tesim, original_location_tesim" 
    ActiveFedora::SolrService.query(qry, rows: 999999, fl: fields)
  end


end
