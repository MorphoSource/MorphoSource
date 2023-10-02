module Morphosource
  module BiologicalSpecimenIdigbioUpdateBehavior
    include Morphosource::MessageHelper

    def update_metadata_from_idigbio_occurrence_id(save_work=false, system_update=false, force_update=false, log_file=nil)
      log = log_file.present?? Logger.new(log_file) : Logger.new(STDOUT) 
      if idigbio_match_found == 1
        @idigbio_occurrence = idigbio_occurrence_id_results[:data].first
        if idigbio_recordset_different_from_org?
          log.debug "iDigBio sync: Specimen #{self.id} not synced because the organization (#{self.organization_id.first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
        else
          @save_work = save_work
          @system_update = system_update
          
          get_idigbio_taxonomy
          get_idigbio_metadata
    
          if force_update || idigbio_record_different_from_specimen?
            apply_idigbio_update
            log.debug "IDigBio sync: Specimen #{id} updated as a result of " + (force_update ? "force_update" : "idigbio_record_different_from_specimen")
          end
        end
      elsif idigbio_match_found > 1
        if system_update
          log.debug "IDigBio sync: Specimen #{id} not synced because multiple records found for OID: #{occurrence_id.first}"
        end
      end
    end

    def idigbio_recordset_different_from_org?
      if (@org_recordset_ids = self.organizations&.first&.recordset_id).present?
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
      # Note: self.taxonomy_id can contain more IDs than taxonomy_id_array since 
      # new taxonomies are added when apply_idigbio_update was called in a previous update
      @canonical_taxonomy_id != self.canonical_taxonomy_ids&.first ||
      (@taxonomy_id_array - self.taxonomy_id.to_a).present? || 
      @taxonomy_params_array.present? ||
      @biospec_model_params.any? do |key, value|
        # case-insensitive comparison for cases like "male" vs. "Male"
        Array(value).map(&:downcase).sort != self.send(key).map(&:downcase).sort
      end
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
        old_taxonomy_id = self.taxonomy_id.to_a
        self.taxonomy_id = (self.taxonomy_id + @taxonomy_id_array).uniq
      end
      if @canonical_taxonomy_id.present?
        old_canonical_taxonomy = self.canonical_taxonomy.to_a
        self.canonical_taxonomy_will_change! unless old_canonical_taxonomy.include? @canonical_taxonomy_id
        self.canonical_taxonomy = (self.canonical_taxonomy << @canonical_taxonomy_id).uniq
      end
  
      if self.taxonomy_id_changed?
        Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : taxonomy_id #{old_taxonomy_id} will be updated to '#{self.taxonomy_id.to_a}'"
      end
      if self.canonical_taxonomy_changed?
        Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : canonical_taxonomy #{old_canonical_taxonomy} will be updated to '#{self.canonical_taxonomy.to_a}'"
      end
    end
  
    def update_metadata_from_idigbio
      # sync bso metadata
      @biospec_model_params.each do |key, value|
        self.send("#{key}=", Array(value) )
        if self.send("#{key}_changed?")
          Rails.logger.debug "UpdateBsoFromIdigbio: BSO #{id} : #{key} field will be updated to '#{value}'"
        end
      end
      if self.idigbio_uuid_changed?
        self.idigbio_link_origin = @system_update ? ["system_generated"] : ["user"]
      end
      self.title = [generated_title]
      self.save if @save_work
    end

    private

    def generated_title
      inst = self.institution_code&.first.presence || ''
      coll = self.collection_code&.first.presence || ''
      cnum = self.catalog_number&.first.presence || ''
      case
      when inst.present? || coll.present? || cnum.present?
        collection_catalog_generated_title(inst, coll, cnum)
      when self.identifier.present?
        identifier_generated_title(self.identifier)
      else
        fallback_generated_title(self.vouchered, ::User.find_by_user_key(self.depositor))
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