# Use this search builder to search both Collections and collection subclasses.
module Morphosource
  class CollectionSearchBuilder < Hyrax::CollectionSearchBuilder

    def collection_classes
      [::Collection, ::MediaList, ::OrganizationCollection, ::SequentialSectionList]
    end
  end
end