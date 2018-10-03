# Generated via
#  `rails generate hyrax:work ImageCaptureEvent`
class ImageCaptureEvent < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = ImageCaptureEventIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ImageCaptureEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata


#  property :ms_creator, predicate: ::RDF::Vocab::DC11.creator, multiple: false do |index|
 #   index.as :stored_searchable
#  end

 # property :ms_description, predicate: ::RDF::Vocab::DC11.description, multiple: false do |index|
#    index.as :stored_searchable
 # end

end
