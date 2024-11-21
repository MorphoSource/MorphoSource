class ProcessingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator
  before_create :date_filter
  before_update :date_filter
  after_save :add_id_to_title

  self.indexer = ProcessingEventIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Media]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ProcessingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # Custom method to handle CarrierWave uploader
  def processing_event_attachment_uploader
    @processing_event_attachment_uploader ||= ProcessingEventAttachmentUploader.new
  end

  # Save the file using CarrierWave
  # param file ActionDispatch::Http::UploadedFile
  def save_uploaded_file(file)
    uploader = processing_event_attachment_uploader
    uploader.work_id = self.id
    uploader.store!(file)
    self.processing_event_attachment = uploader.url
byebug
# is save needed here?
    save!
  end

  def imaging_event
    ancestors.find(&:imaging_event?)
  end

  def media
    descendants.select{ |d| d.media? }
  end

  def objects
    ancestors.select(&:imaging_event?).map(&:objects).flatten
  end

  private
    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("PE#{self.id.to_s}: ")
        self.title.set("PE#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end

    def date_attributes_for_filter
      [ :date_created ]
    end
end
