module Morphosource
  # Module to define core metadata properties for
  # physical object works
  module PhysicalObjectMetadata
	  extend ActiveSupport::Concern

    included do

  # 	  -- custom fields only --

      property :catalog_number, predicate: ::RDF::Vocab::DWC.catalogNumber do |index|
        index.as :stored_searchable
      end

      property :collection_code, predicate: ::RDF::Vocab::DWC.collectionCode do |index|
        index.as :stored_searchable
      end

      # property :current_location, predicate: ::RDF::Vocab::EDM.currentLocation do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :institution, predicate: ::RDF::Vocab::DWC.institutionID do |index|
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

      # TODO review predicates for original_location and periodic_time

      # property :original_location, predicate: ::RDF::Vocab::DC.location do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :original_location, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/original_location") do |index|
        index.as :stored_searchable, :facetable
      end
      #
      # property :periodic_time, predicate: ::RDF::Vocab::DC.period do |index|
      #   index.as :stored_searchable, :facetable
      # end

      property :periodic_time, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/period") do |index|
        index.as :stored_searchable, :facetable
      end

      property :vouchered, predicate: ::RDF::Vocab::DWC.disposition do |index|
        index.as :stored_searchable, :facetable
      end

    end
  end
end
