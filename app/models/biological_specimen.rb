class BiologicalSpecimen < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = BiologicalSpecimenIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ImagingEvent, Attachment]

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::BiologicalSpecimenMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
