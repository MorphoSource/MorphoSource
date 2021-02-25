# Generated via
#  `rails generate hyrax:work EngineeringObject`
class EngineeringObject < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior

  self.indexer = EngineeringObjectIndexer
  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  # validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::EngineeringObjectMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata
end
