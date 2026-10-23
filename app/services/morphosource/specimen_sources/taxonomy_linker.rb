module Morphosource
  module SpecimenSources
    # Links a remote record's provider (canonical) and GBIF taxonomies to existing ones, or queues new ones.
    class TaxonomyLinker
      attr_reader :taxonomy_param_sets, :canonical_taxonomy_id, :taxonomy_id_array, :taxonomy_params_array

      # @param taxonomy_param_sets [Hash] { provider: {...}, gbif: {...} }
      # @return [TaxonomyLinker]
      def self.call(taxonomy_param_sets)
        new(taxonomy_param_sets).tap(&:call)
      end

      def initialize(taxonomy_param_sets)
        @taxonomy_param_sets = taxonomy_param_sets || {}
        @canonical_taxonomy_id = nil
        @taxonomy_id_array = []
        @taxonomy_params_array = []
      end

      def call
        link_provider_taxonomy
        link_gbif_taxonomy
        @taxonomy_id_array = taxonomy_id_array.uniq
      end

      def to_h
        {
          canonical_taxonomy_id: canonical_taxonomy_id,
          taxonomy_id_array: taxonomy_id_array,
          taxonomy_params_array: taxonomy_params_array
        }
      end

      private

        def link_provider_taxonomy
          provider_params = taxonomy_param_sets[:provider]&.to_h&.stringify_keys
          return unless provider_params.present?

          existing = Morphosource::TaxonomySearchService.match_taxonomies_strict(provider_params)
          if existing.present?
            # A GBIF taxonomy can have the same ranks as the provider one, so prefer a non-GBIF match
            match = existing.find { |taxonomy| taxonomy['gbif_key_ssim'].blank? } || existing.first
            @canonical_taxonomy_id = match.id
            @taxonomy_id_array << match.id
          else
            # canonical flag is used after creation to set the canonical taxonomy ID
            @taxonomy_params_array << ActionController::Parameters.new(provider_params.merge('canonical' => true))
          end
        end

        def link_gbif_taxonomy
          gbif_params = taxonomy_param_sets[:gbif]&.to_h&.stringify_keys
          return unless gbif_params.present?

          existing = Morphosource::TaxonomySearchService.call({ gbif_key: gbif_params['gbif_key'] })
          if existing.present?
            @taxonomy_id_array << existing.first.id
          else
            @taxonomy_params_array << ActionController::Parameters.new(gbif_params)
          end
        end
    end
  end
end
