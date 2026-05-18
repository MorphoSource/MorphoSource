# frozen_string_literal: true

module Morphosource
  module CustomQueries
    module Wings
      ##
      # Wings (ActiveFedora) fallback query handler for finding resources by
      # arbitrary metadata attribute conditions, querying Solr via AF.
      #
      # Attribute names are mapped to Solr field names using the standard Hyrax
      # _ssim suffix convention for multi-valued string attributes. Multiple
      # conditions are ANDed together.
      #
      # This handler is a fallback for legacy ActiveFedora records that have not
      # yet been migrated to Postgres. The Postgres handler is preferred; results
      # from both handlers are merged and deduplicated by the find_multiple strategy.
      class FindAllByMetadataProperties
        def self.queries
          [:find_all_by_metadata_properties]
        end

        def initialize(query_service:)
          @query_service = query_service
        end

        attr_reader :query_service
        delegate :resource_factory, to: :query_service

        # Find all resources whose metadata matches the given property conditions.
        #
        # @param properties [Hash] attribute conditions, e.g. { organization_id: "abc" }
        #   Attribute names are translated to Solr fields using the _ssim suffix.
        # @param model [Class, nil] optional Valkyrie resource class; resolved to the
        #   corresponding ActiveFedora class for the Solr query.
        # @return [Array<Valkyrie::Resource>]
        def find_all_by_metadata_properties(properties:, model: nil)
          af_model = model ? model_class_for(model) : ActiveFedora::Base
          solr_conditions = properties.transform_keys { |k| "#{k}_ssim" }
                                      .transform_values { |v| Array.wrap(v).first }
          af_model.where(solr_conditions).map { |obj| resource_factory.to_resource(object: obj) }
        end

        private

        def model_class_for(model)
          internal_resource = model.respond_to?(:internal_resource) ? model.internal_resource : nil
          internal_resource&.safe_constantize || ::Wings::ModelRegistry.lookup(model)
        end
      end
    end
  end
end
