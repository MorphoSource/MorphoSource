module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module OrganizationMetadata
    extend ActiveSupport::Concern

    included do
      property :organization_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/organizationType") do |index|
        index.as :stored_searchable, :facetable
      end

      property :institution_code, predicate: ::RDF::Vocab::DWC.organizationID do |index|
        index.as :stored_searchable
      end

      property :address, predicate: ::RDF::Vocab::DWC.locality do |index|
        index.as :stored_searchable
      end

      property :postal_code, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/postalCode") do |index|
        index.as :stored_searchable
      end

      property :contact_person, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/contactUser") do |index|
        index.as :stored_searchable, :facetable
      end

      property :institution_name, predicate: ::RDF::Vocab::DWC.institutionName do |index|
        index.as :stored_searchable, :facetable
      end

      property :collection_code, predicate: ::RDF::Vocab::DWC.collectionCode do |index|
        index.as :stored_searchable, :facetable
      end

      property :recordset_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/recordsetId") do |index|
        index.as :stored_searchable, :facetable
      end

      property :team_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/team") do |index|
        index.as :stored_searchable
      end

      # -- default media permissions settings --

      # Permissions enforcement mode (whether permissions template is required or recommended, admin-only)
      property :permissions_enforcement_mode, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/permissionsEnforcementMode") do |index|
        index.as :stored_searchable
      end

      # Download permission

      # preferred data manager for published media
      property :data_manager, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/dataManager") do |index|
        index.as :stored_searchable
      end

      # default publication settings
      # determins media visibility, fileset_visibility, fileset_accessibility settings
      property :download_permission, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/publicationStatus"), multiple: true do |index|
        index.as :stored_searchable
      end

      # Rights holder intentionally blank
      property :rights_holder_blank, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/rightsHolderBlank") do |index|
        index.as :stored_searchable
      end

      # License intentionally blank
      property :license_blank, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/licenseBlank") do |index|
        index.as :stored_searchable
      end

      # Rights statement intentionally blank
      property :rights_statement_blank, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/rightsStatementBlank") do |index|
        index.as :stored_searchable
      end
    end
  end
end
