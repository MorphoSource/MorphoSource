# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
class CulturalHeritageObject < ActiveFedora::Base
  include ::Hyrax::WorkBehavior

  self.indexer = CulturalHeritageObjectIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::CulturalHeritageObjectMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
