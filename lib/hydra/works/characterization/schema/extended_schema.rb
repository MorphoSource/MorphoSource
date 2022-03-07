module Hydra::Works::Characterization
  class ExtendedSchema < ActiveTriples::Schema
    property :crc32, predicate: RDF::URI('https://www.morphosource.org/terms/crc32')
    property :external_file, predicate: RDF::URI('https://www.morphosource.org/terms/externalFile')
  end
end
