module Morphosource
  # Module to define core metadata properties for
  # physical object works
  module PhysicalObjectMetadata
    extend ActiveSupport::Concern

    included do

      # -- custom fields only --
      property :organization_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/organizationID") do |index|
        index.as :stored_searchable
      end

      property :catalog_number, predicate: ::RDF::Vocab::DWC.catalogNumber do |index|
        index.as :stored_searchable
      end

      property :collection_code, predicate: ::RDF::Vocab::DWC.collectionCode do |index|
        index.as :stored_searchable
      end

      property :institution_code, predicate: ::RDF::Vocab::DWC.organizationCode do |index|
        index.as :stored_searchable
      end

      property :current_location, predicate: ::RDF::Vocab::EDM.currentLocation do |index|
        index.as :stored_searchable, :facetable
      end

      property :latitude, predicate: RDF::Vocab::EXIF.gpsLatitude do |index|
        index.as :stored_searchable
      end

      property :longitude, predicate: RDF::Vocab::EXIF.gpsLongitude do |index|
        index.as :stored_searchable
      end

      property :numeric_time, predicate: ::RDF::Vocab::DWC.earliestEonOrLowestEonothem do |index|
        index.as :stored_searchable
      end

      property :periodic_time, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/period") do |index|
        index.as :stored_searchable, :facetable
      end

      property :vouchered, predicate: ::RDF::Vocab::DWC.disposition do |index|
        index.as :stored_searchable, :facetable
      end

      property :original_location, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/original_location") do |index|
        index.as :stored_searchable, :facetable
      end

      property :provenance_name, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/provenanceName") do |index|
        index.as :stored_searchable, :facetable
      end

      property :provenance_date, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/provenanceDate") do |index|
        index.as :stored_searchable, :facetable
      end

      property :provenance_details, predicate: ::RDF::Vocab::DC.provenance do |index|
        index.as :stored_searchable, :facetable
      end

      property :provenance_location, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/provenanceLocation") do |index|
        index.as :stored_searchable, :facetable
      end

      property :formation, predicate: ::RDF::Vocab::DWC.formation do |index|
        index.as :stored_searchable, :facetable
      end

      property :context, predicate: ::RDF::Vocab::DWC.geologicalContextID do |index|
        index.as :stored_searchable, :facetable
      end

      property :dating_method, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/datingMethod") do |index|
        index.as :stored_searchable, :facetable
      end

      property :dimensions, predicate: ::RDF::Vocab::DC.format do |index|
        index.as :stored_searchable, :facetable
      end

      property :tgn, predicate: ::RDF::URI.new("http://purl.org/dc/terms/TGN"), class_name: Morphosource::ControlledVocabularies::Getty::Tgn do |index|
        index.as :stored_searchable
      end
    end
  end
end
