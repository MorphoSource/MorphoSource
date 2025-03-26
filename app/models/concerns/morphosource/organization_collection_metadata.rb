module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # Organization Collection
  module OrganizationCollectionMetadata
    extend ActiveSupport::Concern

    included do
      # media ownership transfer
      property :media_ownership_transfer, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/mediaOwnershipTransfer"), multiple: false

      property :ark, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/ark") do |index|
        index.as :stored_searchable
      end

      property :legacy_organization_work_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/legacyOrganizationWorkID"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :agreement_attachment_url, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/agreementAttachmentUrl"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :date_managed, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dateManaged"), multiple: false

      property :continent, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/continent"), multiple: false do |index|
        index.as :facetable, :symbol
      end
    end
  end
end
