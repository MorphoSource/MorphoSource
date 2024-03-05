module Hydra::Works::Characterization
  class ZipContentsSchema < ActiveTriples::Schema
    property :contents_all_files, predicate: RDF::URI('https://www.morphosource.org/terms/contentsAllFiles')
    property :contents_mime_type, predicate: RDF::URI('https://www.morphosource.org/terms/contentsMimeType')
    property :contents_file_name, predicate: RDF::URI('https://www.morphosource.org/terms/contentsFileName')
    property :contents_file_size, predicate: RDF::URI('https://www.morphosource.org/terms/contentsFileSize')
    property :contents_accepted_file_count, predicate: RDF::URI('https://www.morphosource.org/terms/contentsAcceptedFileCount')
  end
end
