module Morphosource
  module MediaListMetadata
    extend ActiveSupport::Concern

    # organization address information
    # physical object original location
    included do
      property :ordered_media, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/orderedMedia") do |index|
        index.as :stored_searchable
      end
    end
  end
end
