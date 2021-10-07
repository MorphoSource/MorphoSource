module Hydra::Works::Characterization
  class ExtendedSchema < ActiveTriples::Schema
    property :crc32, predicate: RDF::URI('https://www.morphosource.org/terms/crc32')
  end
end