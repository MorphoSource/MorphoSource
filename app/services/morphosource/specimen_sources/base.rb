module Morphosource
  module SpecimenSources
    # Interface for a remote specimen source. Subclasses map the source's
    # records to Record objects with MorphoSource specimen/taxonomy params.
    class Base
      # @return [Symbol] key used in Hyrax.config.specimen_record_sources
      def key
        raise NotImplementedError
      end

      # @return [String] display name, e.g. "iDigBio"
      def label
        raise NotImplementedError
      end

      # @return [String] organization Solr field holding this source's dataset IDs
      def org_dataset_field
        raise NotImplementedError
      end

      # @return [Array<Record>] records whose occurrence ID matches exactly (case-insensitive)
      # @raise [SourceError]
      def find_by_occurrence_id(occurrence_id)
        raise NotImplementedError
      end

      # @return [Record, nil]
      # @raise [SourceError]
      def find_by_id(id)
        raise NotImplementedError
      end

      def record_url(id)
        raise NotImplementedError
      end

      # @return [Hash] GBIF backbone taxonomy params for the record
      def gbif_taxonomy_params(record)
        raise NotImplementedError
      end

      # TODO: MR-2029 adds #search(params) for the submission specimen search.

      private

        def occurrence_id_match?(candidate, occurrence_id)
          candidate.to_s.strip.casecmp?(occurrence_id.to_s.strip)
        end

        # Drop sex values not in the controlled vocabulary
        def filter_sex(params)
          return params unless params.key?('sex')
          sex_field_values = Morphosource::SexFieldService.new.option_values
          params.delete('sex') unless sex_field_values.include?(params['sex'].to_s.capitalize)
          params
        end
    end
  end
end
