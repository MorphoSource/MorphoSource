module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module OrganizationMetadata
    extend ActiveSupport::Concern

    included do
      property :institution_code, predicate: ::RDF::Vocab::DWC.organizationID do |index|
        index.as :stored_searchable
      end

      property :address, predicate: ::RDF::Vocab::DWC.locality do |index|
        index.as :stored_searchable
      end

      property :city, predicate: ::RDF::Vocab::DWC.municipality do |index|
        index.as :stored_searchable
      end

      property :state_province, predicate: ::RDF::Vocab::DWC.stateProvince do |index|
        index.as :stored_searchable
      end

      property :country, predicate: ::RDF::Vocab::DWC.country do |index|
        index.as :stored_searchable, :facetable
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

      property :team_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/team") do |index|
        index.as :stored_searchable
      end

      # -- default media permissions settings --

      # Download permission
      # default publication settings
      # determins media visibility, fileset_visibility, fileset_accessibility settings
      property :download_permission, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/publicationStatus"), multiple: true do |index|
        index.as :stored_searchable
      end
    end
  end
end
