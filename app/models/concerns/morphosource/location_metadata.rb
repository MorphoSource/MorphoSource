module Morphosource
  module LocationMetadata
    extend ActiveSupport::Concern

    # organization address information
    # physical object original location
    included do
      property :address, predicate: ::RDF::Vocab::DWC.locality do |index|
        index.as :stored_searchable
      end

      property :city, predicate: ::RDF::Vocab::DWC.municipality do |index|
        index.as :stored_searchable
      end

      property :state_province, predicate: ::RDF::Vocab::DWC.stateProvince do |index|
        index.as :stored_searchable
      end

      property :country, predicate: ::RDF::Vocab::DWC.country do |index|
        index.as :stored_searchable, :facetable
      end
    end
  end
end
