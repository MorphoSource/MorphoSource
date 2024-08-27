module Morphosource
  class IDigBioCompareService
    include Morphosource::MessageHelper

    def self.call(specimen_id, force_update=false)
      new(specimen_id, force_update).call
    end

    def initialize(specimen_id, force_update)
      @force_update = force_update
      @specimen = SolrDocument.find(specimen_id)
    end

    def call
      get_metadata_from_idigbio_occurrence_id(@specimen)
    end

    def get_metadata_from_idigbio_occurrence_id(specimen)
      occurrence_id = specimen["occurrence_id_tesim"]
      if idigbio_match_found(occurrence_id) == 1
        @idigbio_occurrence = @occurrence_id_results[:data].first
        if idigbio_recordset_different_from_org?(specimen)
          Rails.logger.debug "Specimen #{specimen["id"]} not synced because the organization (#{specimen["organization_id_tesim"].first}) has recordset ID(s) (#{@org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{@idb_recordset_id}."
          return nil
        else          
          get_idigbio_taxonomy
          get_idigbio_metadata    
          if @force_update || idigbio_record_different_from_specimen?(specimen)
byebug
            Rails.logger.debug "Specimen #{specimen["id"]} updated as a result of " + (@force_update ? "#force_update" : "idigbio_record_different_from_specimen")
            return {
              :canonical_taxonomy_id => @canonical_taxonomy_id, 
              :taxonomy_id_array => @taxonomy_id_array, 
              :taxonomy_params_array => @taxonomy_params_array, 
              :biospec_model_params => @biospec_model_params                
            }
          else
byebug
            return nil 
          end
        end
      elsif idigbio_match_found(occurrence_id) > 1
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because multiple records found for OID: #{specimen["occurrence_id_tesim"].first}"
        return nil
      end
    end

    def occurrence_id_valid?(occurrence_id)
      # valid if 8 characters minimum AND has both a letter and a number
      occurrence_id.present? && occurrence_id.first.length >= 8 &&
        occurrence_id.first.count("0-9") > 0 && occurrence_id.first.count("a-zA-Z") > 0
    end

    def idigbio_occurrence_id_results(occurrence_id)
      Morphosource::IDigBio.search({'occurrenceid' => occurrence_id})
    end

    def idigbio_match_found(occurrence_id)
      return -1 unless occurrence_id_valid?(occurrence_id)
      @occurrence_id_results = idigbio_occurrence_id_results(occurrence_id)
      return -1 unless (@occurrence_id_results[:status] == :success) && (@occurrence_id_results[:data].length > 0)
      return @occurrence_id_results[:data].length 
    end

    def idigbio_recordset_different_from_org?(specimen)
      org_id = specimen["organization_id_tesim"]
      return false unless org_id.present?
      org = SolrDocument.find(org_id)
      return false unless org.present?
      @org_recordset_ids = org["recordset_id_tesim"]
      if @org_recordset_ids.present?
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

    def idigbio_record_different_from_specimen?(specimen)
      is_diff = false
      if @canonical_taxonomy_id.present? && specimen["canonical_taxonomy_tesim"].present?
        if !specimen["canonical_taxonomy_tesim"].include? @canonical_taxonomy_id  
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: canonical_taxonomy_ids #{specimen["canonical_taxonomy_tesim"]} does not include #{@canonical_taxonomy_id}"
        end
      end
      # Note: taxonomy_id can contain more IDs than taxonomy_id_array since 
      # new taxonomies are added when apply_idigbio_update was called in a previous update
      if specimen["taxonomy_id_tesim"].present?
        if (@taxonomy_id_array - specimen["taxonomy_id_tesim"]).present? 
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_id_array #{@taxonomy_id_array} VS #{specimen["taxonomy_id_tesim"]}"
        end
      end
      if @taxonomy_params_array.present? 
        is_diff = true
        Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_params_array #{@taxonomy_params_array}"
      end
      @biospec_model_params.each do |key, value|
        solr_fields = {
          "idigbio_uuid" => "idigbio_uuid_tesim", 
          "idigbio_recordset_id" => "idigbio_recordset_id_tesim", 
          "vouchered" => "vouchered_tesim", 
          "institution_code" => "institution_code_tesim", 
          "collection_code" => "collection_code_tesim", 
          "catalog_number" => "catalog_number_tesim", 
          "occurrence_id" => "occurrence_id_tesim", 
          "related_url" => "related_url_tesim", 
          "creator" => "creator_tesim", 
          "periodic_time" => "periodic_time_tesim", 
          "original_location" => "original_location_tesim"
        }

        # case-insensitive comparison for cases like "male" vs. "Male"
        if Array(value).map(&:downcase).sort != specimen[solr_fields[key]]&.map(&:downcase)&.sort
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: key=#{key}, #{Array(value)} VS #{specimen[solr_fields[key]]}"
        end      
      end
      return is_diff
    end

  end
end
