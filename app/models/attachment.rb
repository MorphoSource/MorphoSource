# Generated via
#  `rails generate hyrax:work Attachment`
class Attachment < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.work_requires_files = true

  self.indexer = AttachmentIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: 'Your work must have a title.' }

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
