module Morphosource
  class IDigBioUpdateService
    include Morphosource::MessageHelper

    def self.call(bso_id=nil, save_work=false, system_update=false, force_update=false, log_file=nil)
      new(bso_id, save_work, system_update, force_update, log_file).call
    end

    def initialize(bso_id, save_work, system_update, force_update, log_file)
      @save_work = save_work
      @system_update = system_update
      @force_update = force_update
      @log = log_file.present?? Logger.new(log_file) : Logger.new(STDOUT) 
      @bso = BiologicalSpecimen.find(bso_id)
    end

    def call
      update_metadata_from_idigbio_occurrence_id
    end

    def update_metadata_from_idigbio_occurrence_id
      if @bso.idigbio_match_found == 1
        @idigbio_occurrence = @bso.idigbio_occurrence_id_results[:data].first
        if idigbio_recordset_different_from_org?
          @log.debug "IDigBioUpdateService: Specimen #{@bso.id} not synced because the organization (#{@bso.organization_id.first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
        else          
          get_idigbio_taxonomy
          get_idigbio_metadata
byebug   
    
          if @force_update || idigbio_record_different_from_specimen?
            apply_idigbio_update
            @log.debug "IDigBioUpdateService: Specimen #{@bso.id} updated as a result of " + (@force_update ? "force_update" : "idigbio_record_different_from_specimen")
          end
        end
      elsif @bso.idigbio_match_found > 1
        if @system_update
          @log.debug "IDigBioUpdateService: Specimen #{@bso.id} not synced because multiple records found for OID: #{@bso.occurrence_id.first}"
        end
      end
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
  
    def apply_idigbio_update
      add_new_taxonomies
      link_taxonomies
      update_metadata_from_idigbio
    end
  
    def add_new_taxonomies
      # add new taxonomy if any
      @taxonomy_params_array.each do |taxon_params|
        new_taxon_id = prepare_and_create_taxonomy(taxon_params)
        @taxonomy_id_array << new_taxon_id
        if taxon_params[:canonical]
          @canonical_taxonomy_id = new_taxon_id
        end
      end
    end
  
    def link_taxonomies
      # now link taxonomy (new or existing) to the bso
      if @taxonomy_id_array.present?
        old_taxonomy_id = @bso.taxonomy_id.to_a
        @bso.taxonomy_id = (@bso.taxonomy_id + @taxonomy_id_array).uniq
      end
      if @canonical_taxonomy_id.present?
        old_canonical_taxonomy = @bso.canonical_taxonomy.to_a
        @bso.canonical_taxonomy_will_change! unless old_canonical_taxonomy.include? @canonical_taxonomy_id
        @bso.canonical_taxonomy = (@bso.canonical_taxonomy << @canonical_taxonomy_id).uniq
      end
  
      if @bso.taxonomy_id_changed?
        @log.debug "IDigBioUpdateService: BSO #{@bso.id} : taxonomy_id #{old_taxonomy_id} will be updated to '#{@bso.taxonomy_id.to_a}'"
      end
      if @bso.canonical_taxonomy_changed?
        @log.debug "IDigBioUpdateService: BSO #{@bso.id} : canonical_taxonomy #{old_canonical_taxonomy} will be updated to '#{@bso.canonical_taxonomy.to_a}'"
      end
    end
  
    def update_metadata_from_idigbio
      # sync bso metadata
      @biospec_model_params.each do |key, value|
        @bso.send("#{key}=", Array(value) )
        if @bso.send("#{key}_changed?")
          @log.debug "IDigBioUpdateService: BSO #{@bso.id} : #{key} field will be updated to '#{value}'"
        end
      end
      if @bso.idigbio_uuid_changed?
        @bso.idigbio_link_origin = @system_update ? ["system_generated"] : ["user"]
      end
      @bso.title = [generated_title]
      @bso.save if @save_work
    end

    private

    def generated_title
      inst = @bso.institution_code&.first.presence || ''
      coll = @bso.collection_code&.first.presence || ''
      cnum = @bso.catalog_number&.first.presence || ''
      case
      when inst.present? || coll.present? || cnum.present?
        collection_catalog_generated_title(inst, coll, cnum)
      when @bso.identifier.present?
        identifier_generated_title(@bso.identifier)
      else
        fallback_generated_title(@bso.vouchered, ::User.find_by_user_key(@bso.depositor))
      end
    end

    def collection_catalog_generated_title(institution_code='', collection_code='', catalog_number='')
      [institution_code, collection_code, catalog_number].keep_if { |x| x.presence } .join(':')
    end

    def identifier_generated_title(identifier)
      identifier.sort.join(', ')
    end

    def fallback_generated_title(vouchered, user)
      if vouchered.present? && vouchered.first == 'Yes'
        voucher_term = 'Vouchered'
      else
        voucher_term = 'Unvouchered'
      end
      user_term = user.display_name.present? ? user.display_name : user.email
      I18n.t('morphosource.fallback_object_title', voucher: voucher_term, user: user_term)
    end

  end
end
