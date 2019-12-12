module Hydra::Works::Characterization
  class ZipContentsSchema < ActiveTriples::Schema
    property :contents_mime_type, predicate: RDF::URI('https://www.morphosource.org/terms/contentsMimeType')
    property :contents_file_name, predicate: RDF::URI('https://www.morphosource.org/terms/contentsFileName')
    property :contents_file_size, predicate: RDF::URI('https://www.morphosource.org/terms/contentsFileSize')
  end
end
