module Morphosource
  # Module to define metadata properties for
  # processing event activity works
  module ProcessingEventActivityMetadata
  extend ActiveSupport::Concern

  class_methods do
    def sort unsorted_array
      unsorted_array.sort {|a,b| a.index <=> b.index}
    end
  end

  included do
		before_save :index_as_integer

    property :index, predicate: ::RDF::URI.new('https://www.morphosource.org/terms/index'), multiple: false do |index|
      index.as :sortable
    end

    property :processing_activity_type, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/processingActivityType") do |index|
      index.as :stored_searchable
    end

    property :software, predicate: ::RDF::Vocab::DCMIType.Software do |index|
      index.as :stored_searchable
    end

    private
    def index_as_integer
      self.index = index.try :to_i if index.present?
    end
  end
  
  end
end
