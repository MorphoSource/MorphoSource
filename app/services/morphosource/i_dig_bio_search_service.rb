module Morphosource
  # Takes params in the same format as PhysicalObjectsSearchService
  # and uses them to perform an IDigBio query
  class IDigBioSearchService
    attr_reader :params

    # Mapping from PhysicalObjectsSearchService terms to supported IDigBio index fields
    # see: https://github.com/idigbio/idigbio-search-api/wiki/Index-Fields#record-query-fields
    SEARCH_MAPPING = {
      'taxonomy_genus' => 'genus',
      'taxonomy_species' => 'specificepithet',
      'institution_code' => 'institutioncode',
      'collection_code' => 'collectioncode',
      'catalog_number' => 'catalognumber',
      'occurrence_id' => 'occurrenceid',
      'idigbio_uuid' => 'uuid',
      'idigbio_recordset_id' => 'recordset'
    }

    # see: https://docs.google.com/spreadsheets/d/1LJRtcC9cjRNehThsOpnZGLvTny3Zt05aKPIxSlkBzSg/
    IDIGBIO_DATA_BSO_MAPPING = {
      'dwc:institutionCode' => 'institution_code',
      'dwc:collectionCode' => 'collection_code',
      'dwc:catalogNumber' => 'catalog_number',
      'dwc:occurrenceID' => 'occurrence_id',
      'dcterms:references' => 'related_url',
      'dwc:recordedBy' => 'creator',
      'dwc:sex' => 'sex',
      'dwc:decimalLatitude' => 'latitude',
      'dwc:decimalLongitude' => 'longitude',
      'dwc:earliestEpochOrLowestSeries' => 'periodic_time',
      'dwc:locality' => 'original_location',
      'dwc:verbatimLocality' => 'original_location',
      'dwc:country' => 'original_location'
    }

    # these BSO values expect an array (see: Hyrax::BiologicalSpecimenForm.build_permitted_params)
    BSO_ARRAY_VALUES = ['creator','periodic_time','related_url']

    IDIGBIO_TAXONOMY_MAPPING = {
      'dwc:kingdom' => 'taxonomy_kingdom',
      'dwc:phylum' => 'taxonomy_phylum',
      'dwc:class' => 'taxonomy_class',
      'dwc:order' => 'taxonomy_order',
      'dwc:family' => 'taxonomy_family',
      'dwc:genus' => 'taxonomy_genus',
      'dwc:specificEpithet' => 'taxonomy_species',
      'dwc:infraspecificEpithet' => 'taxonomy_subspecies'
    }

    def self.call(params={})
      new(params).call
    end

    # Given an IDigBio UUID, search for the UUID
    # and create MorphoSource BiologicalSpecimen params
    # using the resulting mapped metadata
    def self.biological_specimen_params_from_idigbio(idigbio_uuid)
      # set vouchered to true
      # set description to: "Imported from iDigBio. UUID: {#uuid} Occurrence ID: {#data.occurrence_id}"
      # set idigbio_recordset_id to indexTerms['recordset']
      # set idigbio_uuid to uuid
      # set original_location to whichever of dwc:locality, dwc:verbatimLocality, dwc:country occurs first
      idb = Morphosource::IDigBio.view(idigbio_uuid)
      return self.biological_specimen_params_from_idigbio_result(idb)
    end

    def self.biological_specimen_params_from_occurrence_id(occurrence_id)
      occurrence_id = Array(occurrence_id)&.first&.strip
      return {} unless occurrence_id.present?
      
      results = self.call({ 'occurrence_id' => occurrence_id })
      if results.present? && (results&.first&.dig('data', 'dwc:occurrenceID').downcase == occurrence_id.downcase)
        idb = results.first
        return self.biological_specimen_params_from_idigbio_result(idb)
      else
        return {}
      end
    end

    def self.biological_specimen_params_from_idigbio_result(idb)
      bso_params = {
        'idigbio_uuid' => idb['uuid'],
        'description' => "Imported from iDigBio. UUID: #{idb['uuid']} Occurrence ID: #{idb['data']['dwc:occurrenceID']}",
        'idigbio_recordset_id' => idb['indexTerms']['recordset'],
        'vouchered' => "Yes"
      }
      IDIGBIO_DATA_BSO_MAPPING.each do |key, value|
        if idb['data'].has_key?(key)
          if BSO_ARRAY_VALUES.include?(value)
            bso_params[value] ||= [idb['data'][key]]
          else
            bso_params[value] ||= idb['data'][key]
          end
        end
      end
      return bso_params
    end

    # Given an IDigBio UUID, search for the UUID and create two sets of taxonomy
    # params. The first is based on the data provider supplied 'data' taxonomy.
    # The second is based on iDigBio-corrected 'indexTerms' taxonomies with GBIF links.
    def self.taxonomy_param_sets_from_idigbio(idigbio_uuid)
      idb = Morphosource::IDigBio.view(idigbio_uuid)
      taxonomy_param_sets = { provider: {}, gbif: {} }

      # Construct provider params
      IDIGBIO_TAXONOMY_MAPPING.each do |key, value|
        if idb['data'].has_key?(key)
          taxonomy_param_sets[:provider][value] ||= idb['data'][key]
        end
      end

      # Construct gbif params
      if idb.has_key?('indexTerms') && idb['indexTerms'].has_key?('taxonid')
        taxonomy_param_sets[:gbif] = Morphosource::GbifSearchService.taxonomy_params_from_gbif(idb['indexTerms']['taxonid'], true)
      end

      return taxonomy_param_sets
    end

    def initialize(params={})
      @params = params
    end

    def call
      query = assemble_query
      if query.empty?
        return []
      else
        return Morphosource::IDigBio.search(query)
      end
    end

    private

    def assemble_query
      SEARCH_MAPPING.each_with_object({}) do |(key, value), return_hash|
        if @params.has_key?(key)
          return_hash[value] = @params[key]
        end
      end
    end
  end
end
