module Morphosource
  # Module to define core metadata properties for
  # biological specimen works
  module BiologicalSpecimenMetadata
    extend ActiveSupport::Concern

    included do
      property :taxonomy_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/taxonomyID") do |index|
        index.as :stored_searchable
      end

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

      property :canonical_taxonomy, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/canonicalTaxonomy") do |index|
        index.as :stored_searchable
      end

      property :idigbio_link_origin, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/idigbio_link_origin") do |index|
        index.as :stored_searchable
      end

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:tgn]
      accepts_nested_attributes_for :tgn, reject_if: id_blank, allow_destroy: true
    end
  end
end
