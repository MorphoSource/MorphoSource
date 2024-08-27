module Morphosource
  module MediaListMetadata
    extend ActiveSupport::Concern

    # stores string of media ids in order
    included do
      property :ordered_media, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/orderedMedia") do |index|
        index.as :stored_searchable
      end
      property :list_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/listType") do |index|
        index.as :stored_searchable, :symbol
      end
      property :doi, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/DOI") do |index|
        index.as :stored_searchable, :symbol
      end
    end
  end
end
