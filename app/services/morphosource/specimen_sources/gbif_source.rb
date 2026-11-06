module Morphosource
  module SpecimenSources
    # Specimen records from the GBIF occurrence API
    class GbifSource < Base
      # Darwin Core term (local name) => specimen field
      DATA_BSO_MAPPING = {
        'institutionCode' => 'institution_code',
        'collectionCode' => 'collection_code',
        'catalogNumber' => 'catalog_number',
        'occurrenceID' => 'occurrence_id',
        'references' => 'related_url',
        'recordedBy' => 'creator',
        'sex' => 'sex',
        'decimalLatitude' => 'latitude',
        'decimalLongitude' => 'longitude',
        'earliestEpochOrLowestSeries' => 'periodic_time',
        'locality' => 'original_location',
        'verbatimLocality' => 'original_location',
        'country' => 'original_location'
      }.freeze

      TAXONOMY_MAPPING = {
        'kingdom' => 'taxonomy_kingdom',
        'phylum' => 'taxonomy_phylum',
        'class' => 'taxonomy_class',
        'order' => 'taxonomy_order',
        'family' => 'taxonomy_family',
        'genus' => 'taxonomy_genus',
        'specificEpithet' => 'taxonomy_species',
        'infraspecificEpithet' => 'taxonomy_subspecies'
      }.freeze

      # seconds; short so a slow source falls through to the next one
      LOOKUP_TIMEOUT = 5

      def key
        :gbif
      end

      def label
        'GBIF'
      end

      def org_dataset_field
        'gbif_dataset_key_tesim'
      end

      def find_by_occurrence_id(occurrence_id)
        result = Morphosource::Gbif.occurrence_search({ occurrenceID: occurrence_id, limit: 20 }, timeout: LOOKUP_TIMEOUT)
        raise SourceError, error_message(result) unless result[:status] == :success

        Array(result[:data])
          .select { |occurrence| occurrence_id_match?(occurrence['occurrenceID'], occurrence_id) }
          .map { |occurrence| to_record(occurrence) }
      end

      def find_by_id(occurrence_key)
        return nil unless occurrence_key.present?

        result = Morphosource::Gbif.occurrence(occurrence_key, timeout: LOOKUP_TIMEOUT)
        raise SourceError, error_message(result) unless result[:status] == :success

        result[:data].present? ? to_record(result[:data]) : nil
      end

      def record_url(occurrence_key)
        "https://www.gbif.org/occurrence/#{occurrence_key}"
      end

      def gbif_taxonomy_params(record)
        taxon_key = record.raw['acceptedTaxonKey'].presence || record.raw['taxonKey']
        return {} unless taxon_key.present?
        Morphosource::GbifSearchService.taxonomy_params_from_gbif(taxon_key).presence || {}
      end

      private

        def to_record(occurrence)
          verbatim = verbatim_terms(occurrence['key'])
          Record.new(
            source: self,
            id: occurrence['key'].to_s,
            dataset_id: occurrence['datasetKey'],
            occurrence_id: occurrence['occurrenceID'],
            specimen_params: specimen_params(occurrence, verbatim),
            provider_taxonomy_params: taxonomy_params(verbatim),
            raw: occurrence
          )
        end

        # Verbatim values keyed by DwC local name, or {} if the verbatim record can't be fetched
        def verbatim_terms(occurrence_key)
          result = Morphosource::Gbif.occurrence_verbatim(occurrence_key, timeout: LOOKUP_TIMEOUT)
          unless result[:status] == :success && result[:data].is_a?(Hash)
            Rails.logger.error "SpecimenSources::GbifSource: verbatim lookup failed for #{occurrence_key}: #{error_message(result)}"
            return {}
          end

          result[:data].each_with_object({}) do |(term, value), terms|
            terms[term.to_s.split('/').last] = value.to_s if value.present? && !value.is_a?(Enumerable)
          end
        end

        # original_location is set to whichever of locality, verbatimLocality, country occurs first
        def specimen_params(occurrence, verbatim)
          bso_params = {
            'gbif_occurrence_key' => occurrence['key'].to_s,
            'gbif_dataset_key' => occurrence['datasetKey'],
            'remote_source' => key.to_s,
            'vouchered' => 'Yes'
          }
          DATA_BSO_MAPPING.each do |term, field|
            value = verbatim[term].presence || occurrence[term].presence&.to_s
            next unless value.present?
            bso_params[field] ||= BSO_ARRAY_VALUES.include?(field) ? [value] : value
          end
          filter_sex(bso_params)
        end

        def taxonomy_params(verbatim)
          TAXONOMY_MAPPING.each_with_object({}) do |(term, field), params|
            params[field] = verbatim[term] if verbatim[term].present?
          end
        end

        def error_message(result)
          result[:message] || result[:data].to_s
        end
    end
  end
end
