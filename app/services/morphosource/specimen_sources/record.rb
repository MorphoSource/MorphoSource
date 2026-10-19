module Morphosource
  module SpecimenSources
    # A specimen record found in a remote source, mapped to MorphoSource attributes
    class Record
      attr_reader :source, :id, :dataset_id, :occurrence_id, :specimen_params, :provider_taxonomy_params, :raw

      def initialize(source:, id:, dataset_id:, occurrence_id:, specimen_params:, provider_taxonomy_params:, raw:)
        @source = source
        @id = id
        @dataset_id = dataset_id
        @occurrence_id = occurrence_id
        @specimen_params = specimen_params
        @provider_taxonomy_params = provider_taxonomy_params
        @raw = raw
      end

      def source_key
        source.key
      end

      def source_label
        source.label
      end

      def url
        source.record_url(id)
      end

      def gbif_taxonomy_params
        @gbif_taxonomy_params ||= source.gbif_taxonomy_params(self)
      end

      # @return [Hash] { provider: {...}, gbif: {...} }
      def taxonomy_param_sets
        { provider: provider_taxonomy_params, gbif: gbif_taxonomy_params }
      end
    end
  end
end
