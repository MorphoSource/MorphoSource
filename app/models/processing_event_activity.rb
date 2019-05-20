# Generated via
#  `rails generate hyrax:work ProcessingEventActivity`
class ProcessingEventActivity < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  after_save :build_title_from_components, :generate_index

  self.indexer = ProcessingEventActivityIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }
  
  include Morphosource::ProcessingEventActivityMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  private
    def build_title_from_components
      self.title.set("#{self.processing_activity_type.first.to_s} #{self.software.first.to_s} #{self.description.first.to_s}")
    end

    def generate_index
      self.index.set(self.in_works.first.works.select{|child| child.class == ProcessingEventActivity}.length)
    end
end
