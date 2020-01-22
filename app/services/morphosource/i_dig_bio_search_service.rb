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
      'institution_code' => 'institutioncode'
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
      idb = IDigBio.view(idigbio_uuid)
      bso_params = {
        'idigbio_uuid' => idigbio_uuid,
        'description' => "Imported from iDigBio. UUID: #{idigbio_uuid} Occurrence ID: #{idb['data']['dwc:occurrenceID']}",
        'idigbio_recordset_id' => idb['indexTerms']['recordset'],
        'vouchered' => true
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

    # Given an IDigBio UUID, search for the UUID
    # and create MorphoSource Taxonomy params
    # using the resulting mapped metadata
    def self.taxonomy_params_from_idigbio(idigbio_uuid)
      idb = IDigBio.view(idigbio_uuid)
      taxonomy_params = {}
      IDIGBIO_TAXONOMY_MAPPING.each do |key, value|
        if idb['data'].has_key?(key)
          taxonomy_params[value] ||= idb['data'][key]
        end
      end
      return taxonomy_params
    end

    def initialize(params={})
      @params = params
    end

    def call
      query = assemble_query
      hits = IDigBio.search(query)
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
