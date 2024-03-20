module Hyrax
  class SequentialSectionListsSearchBuilder < CollectionSearchBuilder

    def models
      [::Collection, SequentialSectionList]
    end

  end
end
