# frozen_string_literal: true

module Morphosource
  # Bring more active record like accessors to Valkyrie resources, similar to Hyrax::ArResource
  module ArResource
    extend ActiveSupport::Concern

    # Overrides Hyrax::ArResource#destroy to include deleted_ark in the
    # object.deleted event payload, enabling ARK reservation cleanup on destroy.
    # Does not call super to avoid double-publishing the event.
    def destroy(persister: Hyrax.persister, index_adapter: Hyrax.index_adapter, user: ::User.system_user)
      return false unless persisted?
      deleted_ark = respond_to?(:ark) ? Array(ark).first : nil
      persister.delete(resource: self)
      index_adapter.delete(resource: self)
      Hyrax.publisher.publish('object.deleted', object: self, user: user, deleted_ark: deleted_ark)
      true
    end

    def destroy!(**opts)
      raise Valkyrie::Persistence::ObjectNotFoundError unless destroy(**opts)
    end

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

      # Find all resources matching a set of metadata attribute conditions,
      # scoped to this model class. Supports multiple conditions (ANDed).
      #
      # Routes through the Freyja CustomQueryContainer using the find_multiple
      # strategy, so both Postgres (primary) and Wings/ActiveFedora (fallback)
      # are queried. Results are merged and deduplicated, with Postgres records
      # preferred over Wings records for the same resource ID.
      #
      # @param query_service [#custom_queries] the query service to use
      # @param conditions [Hash] attribute conditions, e.g. organization_id: "abc"
      #   Values may be a single item or an array. For Postgres, all given values
      #   must be present in the stored attribute array (JSONB containment). For
      #   Wings, attribute names are mapped to Solr fields using the _ssim suffix.
      # @return [Array<Valkyrie::Resource>]
      #
      # @example
      #   DeviceResource.where(organization_id: "abc123")
      #   DeviceResource.where(organization_id: "abc123", status: "active")
      def where(query_service: Hyrax.query_service, **conditions)
        query_service.custom_queries.find_all_by_metadata_properties(properties: conditions, model: self)
      end

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
