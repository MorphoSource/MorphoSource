class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(save_work=false, force_update=false)
    specimen_result.each do |hit|      
      if (params_for_update = Morphosource::IDigBioGetMetadataService.call(hit)).present?
        if force_update || Morphosource::IDigBioGetMetadataService.idigbio_record_different_from_specimen?(hit, params_for_update)
          Rails.logger.debug "Specimen #{hit.id} will be updated as a result of " + (force_update ? "force update" : "idigbio record different from specimen")
          if save_work
            UpdateSingleSpecimenFromIdigbioJob.perform_later(hit.id, system_update=true, params_for_update)
          end
        end
      end
    end
  end

  def specimen_result
    qry = "has_model_ssim:BiologicalSpecimen"
    fields = "id, occurrence_id_tesim, organization_id_tesim, canonical_taxonomy_tesim, taxonomy_id_tesim, idigbio_uuid_tesim, idigbio_recordset_id_tesim, vouchered_tesim, institution_code_tesim, collection_code_tesim, catalog_number_tesim, related_url_tesim, creator_tesim, periodic_time_tesim, original_location_tesim" 
    ActiveFedora::SolrService.query(qry, rows: 999999, fl: fields)
  end

end
