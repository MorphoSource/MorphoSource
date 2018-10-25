module Morphosource
  # Module to define core (non-modality specific) metadata properties for
  # media works
  module DeviceMetadata
  extend ActiveSupport::Concern

    included do
      property :modality, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/modality3D") do |index|
        index.as :stored_searchable, :facetable
      end

      property :facility, predicate: ::RDF::URI.new("http://iptc.org/std/Iptc4xmpExt/2008-02-29/LocationCreated") do |index|
        index.as :stored_searchable
      end
    end
  end
end