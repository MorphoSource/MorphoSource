module Hyrax
  module Collections
    module NestedCollectionQueryService

      # update valid child and parent collection types here
      # uses the machine_id of the collection type
      VALID_CHILD_COLLECTION_TYPES = ["project"].freeze
      VALID_PARENT_COLLECTION_TYPES = ["team", "organization"].freeze

      ##
      # @api public
      #
      # What possible collections can be nested within the given parent collection?
      #
      # @param parent [::Collection]
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
      # @return [Array<SolrDocument>]
      def self.available_project_collections(parent:, scope:, limit_to_id: nil)
        return [] unless nestable?(collection: parent)
        return [] unless scope.can?(:edit, parent)
        # projects can't have child collections
        return [] unless valid_parent_collection_type?(parent)

        query_solr(collection: parent, access: :edit, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_child).documents
      end
      define_singleton_method(:available_child_collections, method(:available_project_collections))

      # @api public
      #
      # What possible collections can the given child be nested within?
      #
      # @param child [Collection]
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
      # @return [Array<SolrDocument>]
      def self.available_parent_collections(child:, scope:, limit_to_id: nil)
        return [] unless nestable?(collection: child)
        return [] unless scope.can?(:edit, child)

        # teams can't have parent collections
        child_collection_type = collection_type(child)
        return [] unless valid_child_collection_type?(child_collection_type)

        # projects can have only one parent
        return [] if has_parent?(child)

        query_solr(collection: child, access: :edit, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_parent).documents
      end

      # @api public
      #
      # What collections is the given child nested within?
      #
      # @param child [Collection]
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @param page [Integer] Starting page for pagination
      # @param limit [Integer] Limit to number of collections for pagination
      # @return [Blacklight::Solr::Response]
      def self.parent_collections(child:, scope:, page: 1)
        return [] unless nestable?(collection: child)

        query_builder = Morphosource::NestedCollectionsParentSearchBuilder.new(scope: scope, child: child, page: page)
        scope.blacklight_config.repository.search(query_builder.query)
      end

      def self.query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
        query_builder = Morphosource::Dashboard::NestedCollectionsSearchBuilder.new(
          access: access,
          collection: collection,
          scope: scope,
          nest_direction: nest_direction
        )
        filter_for_nest_direction(query_builder, nest_direction)
        query_builder.where(id: limit_to_id) if limit_to_id
        scope.blacklight_config.repository.search(query_builder.query)
      end
      private_class_method :query_solr

      # @api public
      #
      # @note There is a short-circuit of logic; To be robust, we should ensure that the child and parent are in the corresponding available collections
      #
      # Is it valid to nest the given child within the given parent?
      #
      # @param parent [Collection]
      # @param child [Collection]
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @return [Boolean] true if the parent can nest the child; false otherwise
      # @todo Consider expanding from same collection type to a lookup table that says "This collection type can have within it, these collection types"
      def self.parent_and_child_can_nest?(parent:, child:, scope:)
        return false if parent == child # Short-circuit

        # Projects can have only one parent
        return false if child.member_of_collection_ids.present?

        parent_collection_type = collection_type(parent)
        child_collection_type = collection_type(child)
        return false unless valid_parent_collection_type?(parent_collection_type) && valid_child_collection_type?(child_collection_type)

        return false if available_parent_collections(child: child, scope: scope, limit_to_id: parent.id).none?

        return false if available_child_collections(parent: parent, scope: scope, limit_to_id: child.id).none?
        true
      end

      # @api private
      #
      # @param collection [Hyrax::PcdmCollection,::Collection]
      # @return [Boolean] true if the collection is nestable; otherwise, false
      def self.nestable?(collection:)
        return false if collection.blank?
        return collection.nestable? if collection.respond_to? :nestable?

        Hyrax::CollectionType.for(collection: collection).nestable?
      end
      private_class_method :nestable?

      def self.valid_parent_collection_type?(collection)
        VALID_PARENT_COLLECTION_TYPES.include?(collection_type(collection).machine_id)
      end

      def self.valid_child_collection_type?(collection)
        VALID_CHILD_COLLECTION_TYPES.include?(collection_type(collection).machine_id)
      end

      def self.invalid_parent_collection_type?(collection)
        !valid_parent_collection_type?(collection)
      end

      def self.invalid_child_collection_type?(collection)
        !valid_child_collection_type?(collection)
      end

      def self.collection_type(collection)
        return collection if collection.is_a?(Hyrax::CollectionType)

        Hyrax::CollectionType.find_by_gid!(collection.collection_type_gid)
      end

      def self.has_parent?(child)
        child.member_of_collection_ids&.present? || child.try(:member_of_collection_ids)&.present?
      end

      def self.filter_for_nest_direction(query_builder, nest_direction)
        query_builder["fq"] ||= []
        query_builder["fq"] << nest_direction_filters(nest_direction)
      end

      def self.nest_direction_filters(nest_direction)
        case nest_direction
        when :as_parent
          "(human_readable_type_tesim:(#{VALID_PARENT_COLLECTION_TYPES.map(&:capitalize).join(' OR ')}))"
        when :as_child
          "(human_readable_type_tesim:(#{VALID_CHILD_COLLECTION_TYPES.map(&:capitalize).join(' OR ')}))"
        end
      end
    end
  end
end
