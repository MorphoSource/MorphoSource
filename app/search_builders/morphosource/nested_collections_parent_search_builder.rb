# frozen_string_literal: true
module Morphosource
  # Searches for all collections that are parents of a given collection.
  class NestedCollectionsParentSearchBuilder < Hyrax::NestedCollectionsParentSearchBuilder

    # This overrides the models in FilterByType
    def models
      collection_classes + [OrganizationCollection]
    end

  end
end