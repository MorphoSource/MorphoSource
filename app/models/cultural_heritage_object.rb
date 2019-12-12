class CulturalHeritageObject < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_save :add_id_to_title

  self.indexer = CulturalHeritageObjectIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [ImagingEvent, Attachment]

  validates :title, presence: { message: I18n.t('morphosource.validation.missing.title') }
  validates :vouchered, presence: { message: I18n.t('morphosource.validation.missing.vouchered')}

  include Morphosource::PhysicalObjectMetadata
  include Morphosource::CulturalHeritageObjectMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("C#{self.id.to_s}: ")
        self.title.set("C#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end
end
