module Morphosource
  module SpecimenSources
    # Specimen records from the iDigBio search API
    class IDigBioSource < Base
      # see: https://docs.google.com/spreadsheets/d/1LJRtcC9cjRNehThsOpnZGLvTny3Zt05aKPIxSlkBzSg/
      DATA_BSO_MAPPING = {
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
      }.freeze

      TAXONOMY_MAPPING = {
        'dwc:kingdom' => 'taxonomy_kingdom',
        'dwc:phylum' => 'taxonomy_phylum',
        'dwc:class' => 'taxonomy_class',
        'dwc:order' => 'taxonomy_order',
        'dwc:family' => 'taxonomy_family',
        'dwc:genus' => 'taxonomy_genus',
        'dwc:specificEpithet' => 'taxonomy_species',
        'dwc:infraspecificEpithet' => 'taxonomy_subspecies'
      }.freeze

      # seconds; short so a slow source falls through to the next one
      LOOKUP_TIMEOUT = 5

      def key
        :idigbio
      end

      def label
        'iDigBio'
      end

      def org_dataset_field
        'recordset_id_tesim'
      end

      def find_by_occurrence_id(occurrence_id)
        result = Morphosource::IDigBio.search({ 'occurrenceid' => occurrence_id }, timeout: LOOKUP_TIMEOUT)
        raise SourceError, result[:message] unless result[:status] == :success

        Array(result[:data])
          .select { |idb| occurrence_id_match?(idb.dig('data', 'dwc:occurrenceID'), occurrence_id) }
          .map { |idb| to_record(idb) }
      end

      def find_by_id(uuid)
        return nil unless uuid.present?

        result = Morphosource::IDigBio.view(uuid, timeout: LOOKUP_TIMEOUT)
        raise SourceError, result[:message] unless result[:status] == :success

        result[:data].present? ? to_record(result[:data]) : nil
      end

      def record_url(uuid)
        "https://www.idigbio.org/portal/records/#{uuid}"
      end

      # Search GBIF using the lowest-level provider taxonomic ranks
      def gbif_taxonomy_params(record)
        return {} unless record.provider_taxonomy_params.present?
        Morphosource::GbifSearchService.taxonomy_params_from_gbif_by_terms(record.provider_taxonomy_params).presence || {}
      end

      private

        def to_record(idb)
          Record.new(
            source: self,
            id: idb['uuid'],
            dataset_id: idb.dig('indexTerms', 'recordset'),
            occurrence_id: idb.dig('data', 'dwc:occurrenceID'),
            specimen_params: specimen_params(idb),
            provider_taxonomy_params: taxonomy_params(idb),
            raw: idb
          )
        end

        # original_location is set to whichever of dwc:locality, dwc:verbatimLocality, dwc:country occurs first
        def specimen_params(idb)
          bso_params = {
            'idigbio_uuid' => idb['uuid'],
            'idigbio_recordset_id' => idb.dig('indexTerms', 'recordset'),
            'record_source' => key.to_s,
            'vouchered' => 'Yes'
          }
          data = idb['data'] || {}
          DATA_BSO_MAPPING.each do |key, value|
            next unless data.key?(key)
            bso_params[value] ||= BSO_ARRAY_VALUES.include?(value) ? [data[key]] : data[key]
          end
          filter_sex(bso_params)
        end

        def taxonomy_params(idb)
          data = idb['data'] || {}
          TAXONOMY_MAPPING.each_with_object({}) do |(key, value), params|
            params[value] ||= data[key] if data.key?(key)
          end
        end
    end
  end
end
