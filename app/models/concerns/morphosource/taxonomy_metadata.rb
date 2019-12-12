module Morphosource
  module TaxonomyMetadata
    extend ActiveSupport::Concern

    included do
      # Taxanomic ranks
      property :taxonomy_domain, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/domain") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_kingdom, predicate: ::RDF::Vocab::DWC.kingdom do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_phylum, predicate: ::RDF::Vocab::DWC.phylum do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_superclass, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/superclass") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_class, predicate: ::RDF::Vocab::DWC.class do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_subclass, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/subclass") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_superorder, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/superorder") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_order, predicate: ::RDF::Vocab::DWC.order do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_suborder, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/suborder") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_superfamily, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/superfamily") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_family, predicate: ::RDF::Vocab::DWC.family do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_subfamily, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/subfamily") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_tribe, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/tribe") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_genus, predicate: ::RDF::Vocab::DWC.genus do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_subgenus, predicate: ::RDF::Vocab::DWC.subgenus do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_species, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/species") do |index|
        index.as :stored_searchable, :facetable
      end
      property :taxonomy_subspecies, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/subspecies") do |index|
        index.as :stored_searchable, :facetable
      end

      # Administrative Metadata
      property :trusted, predicate: ::RDF::Vocab::DWC.taxonomicStatus do |index|
        index.as :stored_searchable, :facetable
      end

    end
  end
end
