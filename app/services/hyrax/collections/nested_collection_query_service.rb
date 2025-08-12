module Hyrax
  module Collections
    module NestedCollectionQueryService

      def self.available_child_collections(parent:, scope:, limit_to_id: nil)
        Morphosource::Collections::NestedCollectionQueryService.available_project_collections(parent: parent, scope: scope, limit_to_id: limit_to_id)
      end

      def self.available_parent_collections(child:, scope:, limit_to_id: nil)
        Morphosource::Collections::NestedCollectionQueryService.available_parent_collections(child: child, scope: scope, limit_to_id: limit_to_id)
      end

      def self.parent_collections(child:, scope:, page: 1)
        Morphosource::Collections::NestedCollectionQueryService.parent_collections(child: child, scope: scope, page: page)
      end

      def self.query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
        Morphosource::Collections::NestedCollectionQueryService.query_solr(
          collection: collection,
          access: access,
          scope: scope,
          limit_to_id: limit_to_id,
          nest_direction: nest_direction
        )
      end
      private_class_method :query_solr

      def self.parent_and_child_can_nest?(parent:, child:, scope:)
        Morphosource::Collections::NestedCollectionQueryService.parent_and_child_can_nest?(parent: parent, child: child, scope: scope)
      end

      # @api private
      #
      # @return [Boolean] true if the collection is nestable; otherwise, false
      def self.nestable?(collection:)
        Morphosource::Collections::NestedCollectionQueryService.send(:nestable?, collection: collection)
      end
      private_class_method :nestable?

    end
  end
end
