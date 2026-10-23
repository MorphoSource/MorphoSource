module Morphosource
  class IDigBioGetMetadataService

    attr_reader :specimen, :occurrence_id, :record, :canonical_taxonomy_id, :taxonomy_id_array, :taxonomy_params_array, :biospec_model_params

    SPECIMEN_SOLR_FIELDS = {
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
      "original_location" => "original_location_tesim",
      "sex" => "sex_tesim",
      "latitude" => "latitude_tesim",
      "longitude" => "longitude_tesim",
      "remote_source" => "remote_source_tesim",
      "gbif_occurrence_key" => "gbif_occurrence_key_tesim",
      "gbif_dataset_key" => "gbif_dataset_key_tesim"
    }

    # @param skip_on_source_error [Boolean] skip (return nil) when a higher-priority source failed, rather than fall back to a lower one
    def self.call(solr_doc, skip_on_source_error: false)
      new(solr_doc, skip_on_source_error: skip_on_source_error).call
    end

    def initialize(solr_doc, skip_on_source_error: false)
      @specimen = solr_doc
      @occurrence_id = specimen["occurrence_id_tesim"]
      @skip_on_source_error = skip_on_source_error
    end

    # Returns metadata from the best remote record (see SpecimenSources::Resolver), or nil if none is usable
    def call
      result = Morphosource::SpecimenSources::Resolver
        .new(organization_id: specimen["organization_id_tesim"])
        .find_by_occurrence_id(occurrence_id)

      unless result.found?
        Rails.logger.debug "Specimen #{specimen["id"]} not synced: #{result.status} for OID #{Array(occurrence_id).first}"
        return nil
      end

      if @skip_on_source_error && result.source_errors.any?
        Rails.logger.info "Specimen #{specimen["id"]} not synced: #{result.source_errors.join(', ')} lookup failed, so the #{result.record.source_label} result was not used"
        return nil
      end

      @record = result.record
      get_taxonomy
      @biospec_model_params = record.specimen_params
      return {
        :canonical_taxonomy_id => @canonical_taxonomy_id, 
        :taxonomy_id_array => @taxonomy_id_array, 
        :taxonomy_params_array => @taxonomy_params_array, 
        :biospec_model_params => @biospec_model_params
      }
    end

    def self.idigbio_record_different_from_specimen?(specimen, params_for_update)
      is_diff = false
      canonical_taxonomy_id = params_for_update[:canonical_taxonomy_id]
      taxonomy_id_array = params_for_update[:taxonomy_id_array] || []
      taxonomy_params_array = params_for_update[:taxonomy_params_array] || []
      biospec_model_params = params_for_update[:biospec_model_params] || {}
      if canonical_taxonomy_id.present? && specimen["canonical_taxonomy_tesim"].present? && 
        !specimen["canonical_taxonomy_tesim"].include?(canonical_taxonomy_id)
        is_diff = true
        Rails.logger.debug "is_diff Specimen #{specimen["id"]}: canonical_taxonomy_ids #{specimen["canonical_taxonomy_tesim"]} does not include #{canonical_taxonomy_id}"
      end
      # Note: taxonomy_id can contain more IDs than taxonomy_id_array since 
      # new taxonomies are added when apply_idigbio_update was called in a previous update
      if specimen["taxonomy_id_tesim"].present? && (taxonomy_id_array - specimen["taxonomy_id_tesim"]).present?
        is_diff = true
        Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_id_array #{taxonomy_id_array} VS #{specimen["taxonomy_id_tesim"]}"
      end
      if taxonomy_params_array.present? 
        is_diff = true
        Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_params_array #{taxonomy_params_array}"
      end
      biospec_model_params.each do |key, value|
        # case-insensitive comparison for cases like "male" vs. "Male"
        if Array(value).map(&:downcase).sort != specimen[SPECIMEN_SOLR_FIELDS[key]]&.map(&:downcase)&.sort
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: key=#{key}, #{Array(value)} VS #{specimen[SPECIMEN_SOLR_FIELDS[key]]}"
        end      
      end
      return is_diff
    end

    def get_taxonomy
      linker = Morphosource::SpecimenSources::TaxonomyLinker.call(record.taxonomy_param_sets)
      @canonical_taxonomy_id = linker.canonical_taxonomy_id
      @taxonomy_id_array = linker.taxonomy_id_array
      @taxonomy_params_array = linker.taxonomy_params_array
    end

  end
end
