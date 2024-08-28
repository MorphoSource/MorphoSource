module Morphosource
  class IDigBioGetMetadataService

    attr_reader :specimen, :occurrence_id, :org_recordset_ids, :idigbio_occurrence, :idb_recordset_id, 
      :canonical_taxonomy_id, :taxonomy_id_array, :taxonomy_params_array, :biospec_model_params

    def self.call(specimen_id)
      new(specimen_id).call
    end

    def initialize(specimen_id)
      @specimen = SolrDocument.find(specimen_id)
    end

    def occurrence_id_results
      @occurrence_id_results ||= Morphosource::IDigBio.search({'occurrenceid' => occurrence_id})
    end

    def call
      # Check all conditions to see if a sync is needed
      # Return metadata if all conditions pass.
      @occurrence_id = specimen["occurrence_id_tesim"]
      return nil unless occurrence_id_valid?(occurrence_id)        
      return nil unless (occurrence_id_results[:status] == :success) && (occurrence_id_results[:data].length > 0)

      if occurrence_id_results[:data].length > 1
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because multiple records found for OID: #{specimen["occurrence_id_tesim"].first}"
        return nil
      end

      if idigbio_recordset_different_from_org?(specimen)
        Rails.logger.debug "Specimen #{specimen["id"]} not synced because the organization (#{specimen["organization_id_tesim"].first}) has recordset ID(s) (#{org_recordset_ids.join(', ')}) different from the iDigBio-supplied recordset ID #{idb_recordset_id}."
        return nil
      end

      return get_metadata_from_idigbio_occurrence_id
    end

    def occurrence_id_valid?(occurrence_id)
      # valid if 8 characters minimum AND has both a letter and a number
      occurrence_id.present? && occurrence_id.first.length >= 8 &&
        occurrence_id.first.count("0-9") > 0 && occurrence_id.first.count("a-zA-Z") > 0
    end

    def idigbio_recordset_different_from_org?(specimen)
      org_id = specimen["organization_id_tesim"]
      return false unless org_id.present?
      org = SolrDocument.find(org_id)
      return false unless org.present?
      @org_recordset_ids = org["recordset_id_tesim"]
      if org_recordset_ids.present?
        if (@idb_recordset_id = occurrence_id_results[:data].first.dig("indexTerms", "recordset")).present?
          return !org_recordset_ids.include?(idb_recordset_id)
        end
      end
      return false
    end

    def get_metadata_from_idigbio_occurrence_id
      @idigbio_occurrence = occurrence_id_results[:data].first  
      get_idigbio_taxonomy
      get_idigbio_metadata    
      return {
        :canonical_taxonomy_id => @canonical_taxonomy_id, 
        :taxonomy_id_array => @taxonomy_id_array, 
        :taxonomy_params_array => @taxonomy_params_array, 
        :biospec_model_params => @biospec_model_params
      }
    end

    def get_idigbio_taxonomy
      @canonical_taxonomy_id = nil
      @taxonomy_id_array = []
      @taxonomy_params_array = []
        
      idb_taxonomy_param_sets = Morphosource::IDigBioSearchService.taxonomy_param_sets_from_idigbio(idigbio_occurrence['uuid'])
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
      @taxonomy_id_array = taxonomy_id_array.uniq
    end

    def get_idigbio_metadata
      sex_field_values = Morphosource::SexFieldService.new().option_values
      @biospec_model_params = Morphosource::IDigBioSearchService.
        biological_specimen_params_from_idigbio(idigbio_occurrence['uuid']).
        select do |key, value|
          # filter out invalid sex values
          ( key != "sex" ) || sex_field_values.include?(value.capitalize)
        end  
    end

  end
end
