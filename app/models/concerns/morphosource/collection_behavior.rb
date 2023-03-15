module Morphosource
  module CollectionBehavior
    extend ActiveSupport::Concern

    included do

      property :can_submit_remote_files, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/can_submit_remote_files"), multiple: false 

      property :allowed_remote_source, predicate: ::RDF::URI.new("https://www.morphosource.org/terms/allowed_remote_source"), multiple: false 
  
    end
  end
end
