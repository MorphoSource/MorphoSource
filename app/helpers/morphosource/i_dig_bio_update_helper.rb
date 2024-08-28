# helper methods for iDigBio updates
module Morphosource
  module IDigBioUpdateHelper

    def idigbio_record_different_from_specimen?(specimen, params_for_update)
      is_diff = false
      canonical_taxonomy_id = params_for_update[:canonical_taxonomy_id]
      taxonomy_id_array = params_for_update[:taxonomy_id_array]
      taxonomy_params_array = params_for_update[:taxonomy_params_array]
      biospec_model_params = params_for_update[:biospec_model_params]
      if canonical_taxonomy_id.present? && specimen["canonical_taxonomy_tesim"].present?
        if !specimen["canonical_taxonomy_tesim"].include? canonical_taxonomy_id  
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: canonical_taxonomy_ids #{specimen["canonical_taxonomy_tesim"]} does not include #{canonical_taxonomy_id}"
        end
      end
      # Note: taxonomy_id can contain more IDs than taxonomy_id_array since 
      # new taxonomies are added when apply_idigbio_update was called in a previous update
      if specimen["taxonomy_id_tesim"].present?
        if (taxonomy_id_array - specimen["taxonomy_id_tesim"]).present? 
          is_diff = true
          Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_id_array #{taxonomy_id_array} VS #{specimen["taxonomy_id_tesim"]}"
        end
      end
      if taxonomy_params_array.present? 
        is_diff = true
        Rails.logger.debug "is_diff Specimen #{specimen["id"]}: taxonomy_params_array #{taxonomy_params_array}"
      end
      biospec_model_params.each do |key, value|
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
