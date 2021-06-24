module Morphosource
  module Collections
    module NestedCollectionQueryService
      include Hyrax::Collections::NestedCollectionQueryService

      # taken from NestedCollectionQueryService.available_child_collections
      # (refer to config/initializers/morphosource/nested_collection_query_service.rb)
      # get results of only projects that can be added to a team
      def self.available_project_collections(parent:, scope:, limit_to_id: nil)
        return [] unless parent.try(:nestable?)
        return [] unless scope.can?(:edit, parent)
        return [] unless parent.team?
        # projects can't have child collections
        results = query_solr(collection: parent, access: :edit, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_child).documents
        results
      end

      def self.query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
        nesting_attributes = Hyrax::Collections::NestedCollectionQueryService::NestingAttributes.new(id: collection.id, scope: scope)
        query_builder = Morphosource::Dashboard::NestedCollectionsSearchBuilder.new(
          access: access,
          collection: collection,
          scope: scope,
          nesting_attributes: nesting_attributes,
          nest_direction: nest_direction
        )

        query_builder.where(id: limit_to_id) if limit_to_id
        query = Hyrax::Collections::NestedCollectionQueryService.clean_lucene_error(builder: query_builder)
        scope.repository.search(query)
      end
      private_class_method :query_solr

    end
  end
end
