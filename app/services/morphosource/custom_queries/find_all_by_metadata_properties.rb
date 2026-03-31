# frozen_string_literal: true

module Morphosource
  module CustomQueries
    ##
    # Postgres custom query handler for finding resources by arbitrary metadata
    # attribute conditions using JSONB containment.
    #
    # For each property, the stored metadata array must contain the given value(s).
    # Multiple conditions are ANDed together. Results can optionally be scoped to
    # a specific Valkyrie resource class.
    #
    # @note This handler targets the Postgres adapter only. It is registered
    #   directly on the Postgres sub-service's custom query container (not through
    #   the Freyja CustomQueryContainer) so that the model class is not translated
    #   by Goddess's setup_model before reaching this handler.
    #
    # @example Single condition
    #   DeviceResource.where(organization_id: "abc123")
    #
    # @example Multiple conditions (ANDed)
    #   DeviceResource.where(organization_id: "abc123", status: "active")
    class FindAllByMetadataProperties
      def self.queries
        [:find_all_by_metadata_properties]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service
      delegate :orm_class, to: :resource_factory

      # Find all resources whose metadata matches the given property conditions.
      #
      # @param properties [Hash] attribute conditions to match against JSONB metadata,
      #   e.g. { organization_id: "abc", status: "active" }. Values may be a single
      #   item or an array; in either case the stored metadata array must contain all
      #   of the given values (JSONB containment).
      # @param model [Class, nil] optional Valkyrie resource class used to filter by
      #   internal_resource. Should be the Valkyrie class (e.g. DeviceResource), not
      #   the Wings/ActiveFedora class.
      # @return [Array<Valkyrie::Resource>]
      def find_all_by_metadata_properties(properties:, model: nil)
        containment = properties.transform_keys(&:to_s).transform_values { |v| Array.wrap(v) }
        scope = orm_class.where("metadata @> ?", containment.to_json)
        scope = scope.where(internal_resource: model.to_s) if model
        scope.map { |orm_object| resource_factory.to_resource(object: orm_object) }
      end
    end
  end
end
