class UpdateSpecimensFromIdigbioJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  def perform(save_work=false, system_update=false, force_update=false, log_file=nil)
    @log = log_file.present?? Logger.new(log_file) : Logger.new(STDOUT) 

    qry = "has_model_ssim:BiologicalSpecimen"
    # todo: limiting each document to only iDigBio-specific fields and other fields critical for iDigBio updates
    result = ActiveFedora::SolrService.query(qry, rows: 999999)
    @log.debug "#{result.count} specimens found"
    result.each do |hit|

      bso = BiologicalSpecimen.find(hit.id)

      #- Iterate through each BSO document from Solr

      #-For each document, query the iDigBio API and check if the iDigBio record is different from the specimen (e.g., if an update is needed). 

      update_metadata_from_idigbio_occurrence_id(bso)


      #-This job should only touch Solr, and should not touch FCRepo.


    end
  end

  def update_metadata_from_idigbio_occurrence_id(bso)
      @bso = bso
    flash_notice_if_updated = nil
    if @bso.idigbio_match_found == 1
      @idigbio_occurrence = @bso.idigbio_occurrence_id_results[:data].first
      if idigbio_recordset_different_from_org?
        @log.debug "UpdateSpecimensFromIdigbioJob: Specimen #{@bso.id} not synced because the organization (#{@bso.organization_id.first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
      else          
        get_idigbio_taxonomy
        get_idigbio_metadata    
        if @force_update || idigbio_record_different_from_specimen?

      #-If an update is needed, a second separate iDigBio update job should be used (see next major bullet).
byebug

          UpdateSingleSpecimenFromIdigbioJob.perform_now(@bso.id, @system_update, @log_file,
            @canonical_taxonomy_id, @taxonomy_id_array, @taxonomy_params_array, @biospec_model_params)
          @log.debug "UpdateSpecimensFromIdigbioJob: Specimen #{@bso.id} updated as a result of " + (@force_update ? "#force_update" : "idigbio_record_different_from_specimen")
#          flash_notice_if_updated = "The specimen has been updated to match the iDigBio record."

        end
      end
    elsif @bso.idigbio_match_found > 1
      if @system_update
        @log.debug "UpdateSpecimensFromIdigbioJob: Specimen #{@bso.id} not synced because multiple records found for OID: #{@bso.occurrence_id.first}"
      end
    end
    return flash_notice_if_updated
  end

  def idigbio_recordset_different_from_org?
    if (@org_recordset_ids = @bso.organizations&.first&.recordset_id).present?
      if (@idb_recordset_id = @idigbio_occurrence.dig("indexTerms", "recordset")).present?
        return !@org_recordset_ids.include?(@idb_recordset_id)
      end
    end
    return false
  end

  def get_idigbio_taxonomy
    @canonical_taxonomy_id = nil
    @taxonomy_id_array = []
    @taxonomy_params_array = []
      
    idb_taxonomy_param_sets = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(@idigbio_occurrence['uuid'])
    provider_params = idb_taxonomy_param_sets[:provider]
    gbif_params = idb_taxonomy_param_sets[:gbif]

    if provider_params.present?
      prov = Morphosource::TaxonomySearchService.match_taxonomies_strict(provider_params)
      if prov.present?
        # Exists, link as canonical
        @canonical_taxonomy_id = prov.first.id
        @taxonomy_id_array << prov.first.id
      else
        # Is new, must create
        provider_params[:canonical] = true # to be hooked in later to set canonical taxonomy ID
        @taxonomy_params_array << ActionController::Parameters.new(provider_params)
      end
    end

    if gbif_params.present?
      gbif = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_params['gbif_key'] })
      if gbif.present?
        # Exists, link
        @taxonomy_id_array << gbif.first.id
      else
        # Is new, must create
        @taxonomy_params_array << ActionController::Parameters.new(gbif_params)
      end
    end
    @taxonomy_id_array = @taxonomy_id_array.uniq
  end

  def get_idigbio_metadata
    sex_field_values = Morphosource::SexFieldService.new().option_values
    @biospec_model_params = Morphosource::IDigBioSearchService.
      biological_specimen_params_from_idigbio(@idigbio_occurrence['uuid']).
      select do |key, value|
        # filter out invalid sex values
        ( key != "sex" ) || sex_field_values.include?(value.capitalize)
      end  
  end

  def idigbio_record_different_from_specimen?
    is_diff = false
    if @canonical_taxonomy_id.present? 
      if !@bso.canonical_taxonomy_ids.to_a.include? @canonical_taxonomy_id  
        is_diff = true
        @log.debug "is_diff Specimen #{@bso.id}: canonical_taxonomy_ids #{@bso.canonical_taxonomy_ids.to_a} does not include #{@canonical_taxonomy_id}"
      end
    end
    # Note: @bso.taxonomy_id can contain more IDs than taxonomy_id_array since 
    # new taxonomies are added when apply_idigbio_update was called in a previous update
    if (@taxonomy_id_array - @bso.taxonomy_id.to_a).present? 
      is_diff = true
      @log.debug "is_diff Specimen #{@bso.id}: taxonomy_id_array #{@taxonomy_id_array} VS #{@bso.taxonomy_id.to_a}"
    end
    if @taxonomy_params_array.present? 
      is_diff = true
      @log.debug "is_diff Specimen #{@bso.id}: taxonomy_params_array #{@taxonomy_params_array}"
    end
    @biospec_model_params.each do |key, value|
      # case-insensitive comparison for cases like "male" vs. "Male"
      if Array(value).map(&:downcase).sort != @bso.send(key).map(&:downcase).sort
        is_diff = true
        @log.debug "is_diff Specimen #{@bso.id}: key=#{key}, #{Array(value)} VS #{@bso.send(key).to_a}"
      end      
    end
    return is_diff
  end

end
