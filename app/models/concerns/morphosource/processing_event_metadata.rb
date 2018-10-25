module Morphosource
  # Module to define metadata properties for
  # processing event works
  module ProcessingEventMetadata
  extend ActiveSupport::Concern

  included do

    property :software, predicate: ::RDF::Vocab::DCMIType.Software do |index|
      index.as :stored_searchable
    end

  end
  
  end
end
