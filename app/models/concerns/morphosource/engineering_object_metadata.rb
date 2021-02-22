module Morphosource
  # Module to define core metadata properties for
  # biological specimen works
  module EngineeringObjectMetadata
    extend ActiveSupport::Concern

    included do
      property :description, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/description") do |index|
        index.as :stored_searchable
      end
    end
  end
end
