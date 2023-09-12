module Morphosource
  module My
    module Collections
      class MediaListsSearchBuilder < Morphosource::My::CollectionsSearchBuilder

        self.solr_access_filters_logic -= [:apply_collection_download_permissions]
        self.default_processor_chain -= [:show_only_managed_collections_for_non_admins]

        def models
          [::Collection, MediaList]
        end

        # This overrides the models in FilterByType
        def collection_types
          [Hyrax::CollectionType.find_by(title: "Media List")]
        end

      end
    end
  end
end