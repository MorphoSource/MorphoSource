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
  def attachment_uploader_class
    ProcessingEventAttachmentUploader
  end

  def description_attachment=(file)
byebug
    if file.nil?
byebug
      self.description_attachment_url = nil
    else
      
      # todo: check and delete existing file first


#
#      validate_file_format(file, accepted_formats)

byebug
      uploader = self.attachment_uploader_class.new
      uploader.work_id = self.id
      uploader.store!(file)
      self.description_attachment_url = uploader.url
byebug
    end
  end

  def description_attachment
    self.description_attachment_url
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
