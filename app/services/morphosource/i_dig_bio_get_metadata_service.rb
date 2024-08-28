module Morphosource
  class IDigBioGetMetadataService

    def self.call(specimen_id)
      new(specimen_id).call
    end

    def initialize(specimen_id)
      @specimen = SolrDocument.find(specimen_id)
    end

    def call
      if (occurrence_id = @specimen["occurrence_id_tesim"]).present?
        if (@occurrence_id_results = Morphosource::IDigBio.search({'occurrenceid' => occurrence_id})).present?
          @idigbio_occurrence = @occurrence_id_results[:data].first
        end
      end
      return nil unless @idigbio_occurrence.present?
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

  end
end
