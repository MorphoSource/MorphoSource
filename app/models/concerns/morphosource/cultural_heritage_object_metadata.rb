module Morphosource
  # Module to define core metadata properties for
  # cultural heritage object works
  module CulturalHeritageObjectMetadata
    extend ActiveSupport::Concern

    included do
      property :cho_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choType") do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatType") do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::Vocab::DC.medium do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_material, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatMaterial") do |index|
        index.as :stored_searchable, :facetable
      end

      property :cho_attributes, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choAttributes") do |index|
        index.as :stored_searchable, :facetable
      end

      property :aat_attributes, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/aatAttributes") do |index|
        index.as :stored_searchable, :facetable
      end

      property :short_title, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/shortTitle") do |index|
        index.as :stored_searchable
      end

      property :collection_date, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/collectionDate") do |index|
        index.as :stored_searchable, :facetable
      end

      property :collection_location, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/collectionLocation") do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
