module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # Organization Collection
  module OrganizationCollectionMetadata
    extend ActiveSupport::Concern

    included do
      # media ownership transfer
      property :media_ownership_transfer, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaOwnershipTransfer"), multiple: false
    end
  end
end
