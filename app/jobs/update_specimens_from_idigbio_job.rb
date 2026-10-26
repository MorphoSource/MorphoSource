class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  # @param limit [Integer, String, nil] check only the first N specimens, for timing a run without the full corpus.
  #   Anything that is not a positive integer checks every specimen, since the cron passes a second argument
  #   that predates this one.
  def perform(save_work=false, force_update=false, limit=nil)
    counts = Hash.new(0)
    sources = Hash.new(0)
    fields = Hash.new(0)
    started = Time.now
    specimen_result(limit.to_s[/\A[1-9]\d*\z/]&.to_i).each do |hit|      
      counts[:checked] += 1
      # A failed higher-priority source skips the specimen this week instead of switching it to a lower-priority source
      service = Morphosource::IDigBioGetMetadataService.new(hit, skip_on_source_error: true)
      if (params_for_update = service.call).present?
        sources[service.record.source_key] += 1
        changed = Morphosource::IDigBioGetMetadataService.changed_fields(hit, params_for_update)
        changed.each { |field| fields[field] += 1 }
        if force_update || changed.any?
          Rails.logger.debug "Specimen #{hit.id} will be updated as a result of " + (force_update ? "force update" : "changed fields: #{changed.join(', ')}")
          counts[:to_update] += 1
          if save_work
            # params_for_update can contain ActionController::Parameters, 
            # which will raise UnfilteredParameters when passed to the job
            # Therefore, recursively convert any ActionController::Parameters to Hash first
            normalized_params = deep_normalize_for_job(params_for_update)
            UpdateSingleSpecimenFromIdigbioJob.perform_later(hit.id, system_update=true, normalized_params)
            counts[:enqueued] += 1
          end
        end
      else
        # A whole run of source errors means the source was down, not that the specimens are unknown to it
        counts[service.source_errors.any? ? :source_error : :no_record] += 1
      end
    end
    Rails.logger.info "UpdateSpecimensFromIdigbioJob: #{counts[:checked]} checked, #{counts[:to_update]} to update, " \
                      "#{counts[:enqueued]} enqueued, #{counts[:no_record]} with no usable record, " \
                      "#{counts[:source_error]} skipped after a source lookup failed, " \
                      "in #{(Time.now - started).round}s"
    Rails.logger.info "UpdateSpecimensFromIdigbioJob records by source: #{tally_text(sources)}"
    Rails.logger.info "UpdateSpecimensFromIdigbioJob fields that would change: #{tally_text(fields)}"
  end

  def specimen_result(limit = nil)
    qry = "has_model_ssim:BiologicalSpecimen"
    fields = "id, occurrence_id_tesim, organization_id_tesim, canonical_taxonomy_tesim, taxonomy_id_tesim, idigbio_uuid_tesim, idigbio_recordset_id_tesim, vouchered_tesim, institution_code_tesim, collection_code_tesim, catalog_number_tesim, related_url_tesim, creator_tesim, periodic_time_tesim, original_location_tesim, sex_tesim, latitude_tesim, longitude_tesim, remote_source_tesim, gbif_occurrence_key_tesim, gbif_dataset_key_tesim" 
    ActiveFedora::SolrService.query(qry, rows: limit || 999999, fl: fields)
  end

  private

  # "a=3, b=1" in descending count order
  def tally_text(tally)
    return 'none' if tally.empty?
    tally.sort_by { |_, count| -count }.map { |name, count| "#{name}=#{count}" }.join(', ')
  end

  # Recursively convert ActionController::Parameters to Hash
  def deep_normalize_for_job(obj)
    case obj
    when ActionController::Parameters
      obj.to_unsafe_h
    when Hash
      obj.transform_values { |v| deep_normalize_for_job(v) }
    when Array
      obj.map { |v| deep_normalize_for_job(v) }
    else
      obj
    end
  end
end
