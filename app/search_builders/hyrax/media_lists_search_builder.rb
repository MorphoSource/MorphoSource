module Hyrax
  class MediaListsSearchBuilder < CollectionSearchBuilder

    def models
      [::Collection, MediaList]
    end

  end
end
