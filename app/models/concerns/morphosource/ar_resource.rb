# frozen_string_literal: true

module Morphosource
  # Adds ActiveRecord-like .first and .last class methods to Valkyrie resource models.
  #
  # @example
  #   class TaxonomyResource < Hyrax::Work
  #     include Morphosource::ArResource
  #   end
  #
  #   TaxonomyResource.first  #=> first TaxonomyResource by created_at
  #   TaxonomyResource.last   #=> last TaxonomyResource by created_at
  #
  # @note When using FreyjaWithWings as the metadata adapter, .first and .last
  #   use the :find_single_or_nil Goddess query strategy. This means Postgres
  #   (Valkyrie) is queried first; Wings (ActiveFedora) is only consulted as a
  #   fallback when no Postgres record exists. The result is the first/last
  #   Valkyrie record by created_at, NOT the globally oldest/newest record
  #   across both stores. If both Valkyrie and ActiveFedora records exist for
  #   the same model, ActiveFedora records are effectively ignored.
  module ArResource
    extend ActiveSupport::Concern

    class_methods do
      # Determine whether a record exists, mirroring ActiveRecord::Base.exists?.
      #
      # @overload exists?(id)
      #   @param id [String, Valkyrie::ID] a resource ID to look up
      # @overload exists?(conditions)
      #   @param conditions [Hash] attribute conditions to pass to find_by
      # @return [Boolean]
      def exists?(id_or_conditions = nil, **conditions)
        return false if id_or_conditions == false
        return false if id_or_conditions.nil? && conditions.empty?

        if id_or_conditions.is_a?(Hash)
          !!find_by(**id_or_conditions.merge(conditions))
        elsif id_or_conditions
          !!find_by(id: id_or_conditions)
        else
          !!find_by(**conditions)
        end
      rescue StandardError
        false
      end

      # Find the first resource of this type (oldest by created_at).
      #
      # @param query_service [#custom_queries] the query service to use
      # @return [Valkyrie::Resource, nil]
      def first(query_service: Hyrax.query_service)
        query_service.custom_queries.find_first_of_model(model: self)
      end

      # Find the last resource of this type (newest by created_at).
      #
      # @param query_service [#custom_queries] the query service to use
      # @return [Valkyrie::Resource, nil]
      def last(query_service: Hyrax.query_service)
        query_service.custom_queries.find_last_of_model(model: self)
      end
    end
  end
end
