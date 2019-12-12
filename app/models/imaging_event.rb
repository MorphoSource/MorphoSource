class ImagingEventParentDeviceModalityValidator < ActiveModel::Validator
  def validate(imaging_event)
    parent_devices = imaging_event.in_works.select{|w| w.class == Device}
    if parent_devices.length > 0
      parent_modalities = parent_devices.map{|d| d.modality.to_a}.flatten.uniq
      if parent_modalities.length > 0
        unless parent_modalities.include?(imaging_event.ie_modality.first)
          imaging_event.errors[:ie_modality] << "Imaging Event modality \"#{imaging_event.ie_modality.first}\" does not match parent device modalities: #{parent_modalities.join(', ')}"
        end
      end
    end
  end
end

class ImagingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator, ImagingEventParentDeviceModalityValidator
  after_save :add_id_to_title

  self.work_requires_files = false
  self.indexer = ImagingEventIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Media, ProcessingEvent, Attachment]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ImagingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata


#  property :ms_creator, predicate: ::RDF::Vocab::DC11.creator, multiple: false do |index|
 #   index.as :stored_searchable
#  end

 # property :ms_description, predicate: ::RDF::Vocab::DC11.description, multiple: false do |index|
#    index.as :stored_searchable
 # end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("IE#{self.id.to_s}: ")
        self.title.set("IE#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end
end
