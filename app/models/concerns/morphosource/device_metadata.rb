module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module DeviceMetadata
  extend ActiveSupport::Concern

    included do
      property :modality, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/modality3D") do |index|
        index.as :stored_searchable, :symbol
      end

      property :organization_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/organizationID") do |index|
        index.as :stored_searchable, :symbol
      end

      property :ark, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/ark") do |index|
        index.as :stored_searchable
      end
    end
  end
end