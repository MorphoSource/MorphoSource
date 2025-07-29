module Hyrax
  module Collections
    module NestedCollectionQueryService
      # @api public
      #
      # What possible collections can be nested within the given parent collection?
      #
      # @param parent [Collection]
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
      # @return [Array<SolrDocument>]
      def self.available_child_collections(parent:, scope:, limit_to_id: nil)
        return [] unless nestable?(collection: parent)
        return [] unless scope.can?(:edit, parent)

        # projects can't have child collections
        parent_collection_type = Hyrax::CollectionType.find_by_gid!(parent.collection_type_gid)
        return [] if (parent_collection_type.machine_id == "project")

        results = query_solr(collection: parent, access: :read, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_child).documents
        # if parent is a team, return only projects without parents
        results.select!{ |r| r["nesting_collection__parent_ids_ssim"].nil? } if valid_parent_collection_type?(parent_collection_type)
        results
      end

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
        byebug
        # teams can't have parent collections
        child_collection_type = Hyrax::CollectionType.find_by_gid!(child.collection_type_gid)
        return [] unless valid_child_collection_type?(child_collection_type)
        # projects can have only one parent
        byebug
        return [] if valid_child_collection_type?(child_collection_type) && child.member_of_collection_ids.present?
        byebug
        query_solr(collection: child, access: :deposit, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_parent).documents
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
        query_builder = Hyrax::NestedCollectionsParentSearchBuilder.new(scope: scope, child: child, page: page)
        scope.blacklight_config.repository.search(query_builder.query)
      end

      # @api private
      #
      # @param collection [Collection]
      # @param access [Symbol] I need this kind of permission on the queried objects.
      # @param scope [Object] Typically a controller object that responds to `repository`, `can?`, `blacklight_config`, `current_ability`
      # @param limit_to_id [nil, String] Limit the query to just check if the given id is in the response. Useful for validation.
      # @param nest_direction [Symbol] :as_child or :as_parent
      def self.query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
        query_builder = Morphosource::Dashboard::NestedCollectionsSearchBuilder.new(
          access: access,
          collection: collection,
          scope: scope,
          nest_direction: nest_direction
        )
        byebug
        query_builder.where(id: limit_to_id.to_s) if limit_to_id
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
        parent_collection_type = Hyrax::CollectionType.find_by_gid!(parent.collection_type_gid)
        child_collection_type = Hyrax::CollectionType.find_by_gid!(child.collection_type_gid)
        if parent.collection_type_gid != child.collection_type_gid
          # Teams and organizations are able to have child projects
          return false unless valid_parent_collection_type?(parent_collection_type) && valid_child_collection_type?(child_collection_type)
          # Projects can have only one parent
          return false if child.member_of_collection_ids.present?
        else
          return false
        end
        return false if available_parent_collections(child: child, scope: scope, limit_to_id: parent.id).none?
        byebug
        return false if available_child_collections(parent: parent, scope: scope, limit_to_id: child.id).none?
        byebug
        true
      end

      # @api private
      #
      # @param collection [Hyrax::PcdmCollection,::Collection]
      # @return [Boolean] true if the collection is nestable; otherwise, false
      def self.nestable?(collection:)
        return false if collection.blank?
        return collection.nestable? if collection.respond_to? :nestable?
        collection_type = Hyrax::CollectionType.find_by_gid!(collection.collection_type_gid)
        collection_type.nestable?
      end
      private_class_method :nestable?

      def self.valid_parent_collection_type?(parent_collection_type)
        ["team", "organization"].include?(parent_collection_type.machine_id)
      end

      def self.valid_child_collection_type?(child_collection_type)
        ["project"].include?(child_collection_type.machine_id)
      end
    end
  end
end
