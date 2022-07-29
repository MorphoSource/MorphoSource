module Morphosource
  # Module to define core metadata properties for
  # cultural heritage object works
  module CulturalHeritageObjectMetadata
    extend ActiveSupport::Concern

    included do
      property :cho_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choType") do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatType"), class_name: Morphosource::ControlledVocabularies::Getty::Aat do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::Vocab::DC.medium do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_material, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatMaterial"), class_name: Morphosource::ControlledVocabularies::Getty::Aat do |index|
        index.as :stored_searchable, :facetable
      end

      property :cho_attribute, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choAttribute") do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_attribute, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatAttribute"), class_name: Morphosource::ControlledVocabularies::Getty::Aat do |index|
        index.as :stored_searchable, :facetable
      end

      property :short_title, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/shortTitle") do |index|
        index.as :stored_searchable
      end

      property :aat_period, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatPeriod"), class_name: Morphosource::ControlledVocabularies::Getty::Aat do |index|
        index.as :stored_searchable, :facetable
      end

      id_blank = proc { |attributes| attributes[:id].blank? }

      class_attribute :controlled_properties
      self.controlled_properties = [:aat_attribute, :aat_material, :aat_period, :aat_type, :based_near, :tgn]
      accepts_nested_attributes_for :aat_attribute, :aat_material, :aat_period, :aat_type, :based_near, :tgn, reject_if: id_blank, allow_destroy: true
    end
  end
end
