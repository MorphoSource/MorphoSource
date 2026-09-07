module Morphosource
  # Module to define metadata properties for
  # processing event works
  module ProcessingEventMetadata
    extend ActiveSupport::Concern

    included do

      property :software, predicate: ::RDF::Vocab::DCMIType.Software do |index|
        index.as :stored_searchable
      end

      property :processing_activity, predicate: ::RDF::URI.new("http://rs.tdwg.org/ac/terms/resourceCreationTechnique") do |index|
        index.as :stored_searchable
      end

      property :processing_activity_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/processingActivityType") do |index|
        index.as :stored_searchable
      end

      property :processing_activity_software, predicate: ::RDF::URI.new("http://dublincore.org/documents/dcmi-terms/#dcmitype-Software") do |index|
        index.as :stored_searchable
      end

      property :processing_activity_description, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/processingActivityDescription") do |index|
        index.as :stored_searchable
      end

      property :description_attachment_url, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/descriptionAttachmentUrl"), multiple: false do |index|
        index.as :stored_searchable
      end

      property :imaging_event_id, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/imagingEventId"), multiple: false do |index|
        index.as :stored_searchable
      end

    end
  
  end
end
