class CulturalHeritageObject < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  include ::Morphosource::PhysicalObjectBehavior
  validates_with Morphosource::ParentChildValidator

  self.indexer = CulturalHeritageObjectIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::CulturalHeritageObjectMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  def taxonomies # TODO remove later after refactoring media_indexer
    []
  end

  def taxonomies_titles # TODO remove later after refactoring media_indexer
    []
  end
end
