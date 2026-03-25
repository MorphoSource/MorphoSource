# frozen_string_literal: true

module Morphosource
  module CustomQueries
    module Wings
      ##
      # Wings-optimized custom query handler for finding the first or last
      # resource of a given model type.
      #
      # Uses ActiveFedora's .first and .last which query Solr with rows: 1.
      class FindFirstAndLastOfModel
        def self.queries
          [:find_first_of_model, :find_last_of_model]
        end

        def initialize(query_service:)
          @query_service = query_service
        end

        attr_reader :query_service
        delegate :resource_factory, to: :query_service

        # @param model [Class] the Valkyrie resource class
        # @return [Valkyrie::Resource, nil]
        def find_first_of_model(model:)
          af_object = model_class_for(model).first
          return nil unless af_object
          resource_factory.to_resource(object: af_object)
        end

        # @param model [Class] the Valkyrie resource class
        # @return [Valkyrie::Resource, nil]
        def find_last_of_model(model:)
          af_object = model_class_for(model).last
          return nil unless af_object
          resource_factory.to_resource(object: af_object)
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
