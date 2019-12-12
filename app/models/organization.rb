class Organization < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = OrganizationIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Device, BiologicalSpecimen, CulturalHeritageObject, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::OrganizationMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
