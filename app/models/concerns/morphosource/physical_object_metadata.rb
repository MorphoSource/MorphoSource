module Morphosource
  # Module to define core metadata properties for
  # physical object works
  module PhysicalObjectMetadata
	extend ActiveSupport::Concern
#
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

    property :physical_object_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/physicalObjectType") do |index|
      index.as :stored_searchable, :facetable
    end

    # Biological Specimens
    property :idigbio_recordset_id, predicate: ::RDF::Vocab::DWC.datasetID do |index|
      index.as :stored_searchable
    end

    property :idigbio_uuid, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/idigbioUUID") do |index|
      index.as :stored_searchable
    end

    property :is_type_specimen, predicate: ::RDF::Vocab::DWC.typeStatus do |index|
      index.as :stored_searchable, :facetable
    end

    property :occurrence_id, predicate: ::RDF::Vocab::DWC.occurrenceID do |index|
      index.as :stored_searchable
    end

    property :sex, predicate: ::RDF::Vocab::DWC.sex do |index|
      index.as :stored_searchable, :facetable
    end

    # Cultural Heritage Objects
    property :cho_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choType") do |index|
      index.as :stored_searchable, :facetable
    end

    property :material, predicate: ::RDF::Vocab::DC.medium do |index|
      index.as :stored_searchable, :facetable
    end

	end
  end
end
