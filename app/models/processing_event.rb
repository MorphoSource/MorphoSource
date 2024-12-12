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
  def uploader
    @uploader ||= ProcessingEventAttachmentUploader.new.tap { |u| u.work_id = id }
  end

  # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached, or nil to delete the file
  def description_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.description_attachment_url.present?
      file_name = File.basename(self.description_attachment_url)
      uploader.retrieve_from_store!(file_name)
      if uploader.file && File.exist?(uploader.file.path)
        Rails.logger.info "Deleting file: #{uploader.file.path}"
        uploader.remove!
      else
        Rails.logger.warn "File not found: #{uploader.file&.path}"
      end
      self.description_attachment_url = nil
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if Morphosource.attachment_formats.include?(extension)
        uploader.work_id = self.id
        uploader.store!(file)
        self.description_attachment_url = uploader.url
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
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
