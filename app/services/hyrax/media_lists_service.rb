module Hyrax
  class MediaListsService < CollectionsService

    self.list_search_builder_class = Hyrax::MediaListsSearchBuilder

  end
end
