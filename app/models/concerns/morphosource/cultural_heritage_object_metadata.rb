module Morphosource
  # Module to define core metadata properties for
  # cultural heritage object works
  module CulturalHeritageObjectMetadata
    extend ActiveSupport::Concern

    included do
      property :cho_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/choType") do |index|
        index.as :stored_searchable, :facetable
      end

      property :material, predicate: ::RDF::Vocab::DC.medium do |index|
        index.as :stored_searchable, :facetable
      end
    end

  end
end
