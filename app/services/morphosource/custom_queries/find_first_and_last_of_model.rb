# frozen_string_literal: true

module Morphosource
  module CustomQueries
    ##
    # Postgres-optimized custom query handler for finding the first or last
    # resource of a given model type, ordered by created_at.
    class FindFirstAndLastOfModel
      def self.queries
        [:find_first_of_model, :find_last_of_model]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service
      delegate :orm_class, to: :resource_factory

      # Find the first resource of the given model type (oldest by created_at).
      #
      # @param model [Class] the Valkyrie resource class
      # @return [Valkyrie::Resource, nil]
      def find_first_of_model(model:)
        orm_object = orm_class
          .where(internal_resource: model.to_s)
          .order(created_at: :asc)
          .first
        return nil unless orm_object
        resource_factory.to_resource(object: orm_object)
      end

      # Find the last resource of the given model type (newest by created_at).
      #
      # @param model [Class] the Valkyrie resource class
      # @return [Valkyrie::Resource, nil]
      def find_last_of_model(model:)
        orm_object = orm_class
          .where(internal_resource: model.to_s)
          .order(created_at: :desc)
          .first
        return nil unless orm_object
        resource_factory.to_resource(object: orm_object)
      end
    end
  end
end
