module Hyrax
  module Collections
    module MsNestedCollectionQueryService
      include NestedCollectionQueryService

      # taken from NestedCollectionQueryService.available_child_collections
      # (refer to config/initializers/morphosource/nested_collection_query_service.rb)
      # get results of only projects that can be added to a team
      def self.available_project_collections(parent:, scope:, limit_to_id: nil)
        return [] unless parent.try(:nestable?)
        return [] unless scope.can?(:deposit, parent)
        # projects can't have child collections
        results = query_solr(collection: parent, access: :read, scope: scope, limit_to_id: limit_to_id, nest_direction: :as_child).documents
        # return only projects without parents
        results.select!{ |r| r["nesting_collection__parent_ids_ssim"].nil? } 
        results
      end

      # taken from NestedCollectionQueryService
      def self.query_solr(collection:, access:, scope:, limit_to_id:, nest_direction:)
        nesting_attributes = NestingAttributes.new(id: collection.id, scope: scope)
        query_builder = Hyrax::Dashboard::NestedCollectionsSearchBuilder.new(
          access: access,
          collection: collection,
          scope: scope,
          nesting_attributes: nesting_attributes,
          nest_direction: nest_direction
        )

        query_builder.where(id: limit_to_id) if limit_to_id
        query = NestedCollectionQueryService.clean_lucene_error(builder: query_builder)
        scope.repository.search(query)
      end
      private_class_method :query_solr

    end
  end
end
