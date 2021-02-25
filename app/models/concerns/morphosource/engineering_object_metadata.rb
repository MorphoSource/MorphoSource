module Morphosource
  # Module to define core metadata properties for
  # biological specimen works
  module EngineeringObjectMetadata
    extend ActiveSupport::Concern

    included do
      property :institution_code, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/institution_code") do |index|
        index.as :stored_searchable, :facetable
      end

      property :catalog_number, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/catalog_number") do |index|
        index.as :stored_searchable, :facetable
      end

      property :description, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/description") do |index|
        index.as :stored_searchable
      end

      property :is_pak, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/is_pak") do |index|
        index.as :stored_searchable, :facetable
      end

      property :is_built_in_fiducials_present, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/is_built_in_fiducials_present") do |index|
        index.as :stored_searchable, :facetable
      end

      property :snl_assembler, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/snl_assembler") do |index|
        index.as :stored_searchable, :facetable
      end

      property :assembly_date, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/assembly_date") do |index|
        index.as :stored_searchable, :facetable
      end
      
      property :preparation_notes, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/preparation_notes") do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
