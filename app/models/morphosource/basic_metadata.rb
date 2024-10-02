# frozen_string_literal: true
module Morphosource
  # An optional model mixin to define some simple properties. The list of metadata terms is the same
  # as in Hyrax::BasicMetadata, but that module also finalizes metadata terms with
  # accepts_nested_attributes_for. A few Morphosource models (BiologicalSpecimen, etc.) need to
  # override and specify different attributes in accepts_nested_attributes_for, so this module
  # exists to support and enable that override. The list of terms should be kept up to date with
  # Hyrax::BasicMetadata.
  module BasicMetadata
    extend ActiveSupport::Concern

    included do
      property :alternative_title, predicate: ::RDF::Vocab::DC.alternative

      property :label, predicate: ActiveFedora::RDF::Fcrepo::Model.downloadFilename, multiple: false

      property :relative_path, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#relativePath'), multiple: false

      property :import_url, predicate: ::RDF::URI.new('http://scholarsphere.psu.edu/ns#importUrl'), multiple: false
      property :resource_type, predicate: ::RDF::Vocab::DC.type
      property :creator, predicate: ::RDF::Vocab::DC11.creator
      property :contributor, predicate: ::RDF::Vocab::DC11.contributor
      property :description, predicate: ::RDF::Vocab::DC11.description
      property :abstract, predicate: ::RDF::Vocab::DC.abstract
      property :keyword, predicate: ::RDF::Vocab::SCHEMA.keywords
      # Used for a license
      property :license, predicate: ::RDF::Vocab::DC.license, multiple: true

      property :rights_notes, predicate: ::RDF::URI.new('http://purl.org/dc/elements/1.1/rights'), multiple: true

      # This is for the rights statement
      property :rights_statement, predicate: ::RDF::Vocab::EDM.rights
      property :access_right, predicate: ::RDF::Vocab::DC.accessRights
      property :publisher, predicate: ::RDF::Vocab::DC11.publisher
      property :date_created, predicate: ::RDF::Vocab::DC.created
      property :subject, predicate: ::RDF::Vocab::DC11.subject
      property :language, predicate: ::RDF::Vocab::DC11.language
      property :identifier, predicate: ::RDF::Vocab::DC.identifier
      property :based_near, predicate: ::RDF::Vocab::FOAF.based_near, class_name: Hyrax::ControlledVocabularies::Location
      property :related_url, predicate: ::RDF::RDFS.seeAlso
      property :bibliographic_citation, predicate: ::RDF::Vocab::DC.bibliographicCitation
      property :source, predicate: ::RDF::Vocab::DC.source
    end
  end
end
