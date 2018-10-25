class Media < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior

  self.work_requires_files = true

  self.indexer = MediaIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::MediaMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
