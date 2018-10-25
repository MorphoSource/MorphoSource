module Morphosource
  # Module to define core metadata properties for
  # biological specimen works
  module BiologicalSpecimenMetadata
    extend ActiveSupport::Concern

    included do
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
    end

  end
end
