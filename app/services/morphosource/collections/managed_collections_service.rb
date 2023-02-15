module Hyrax
  module Collections
    module ManagedCollectionsService

      def self.managed_media_lists_count(scope:)
        query_builder = Hyrax::Dashboard::CollectionsSearchBuilder.new(scope).rows(0)
        scope.repository.search(query_builder.query).response["numFound"]
      end
    end
  end
end
