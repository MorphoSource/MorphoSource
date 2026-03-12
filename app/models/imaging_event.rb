class ImagingEventParentDeviceModalityValidator < ActiveModel::Validator

  def validate(imaging_event)
    get_validation_values(imaging_event)
    validate_device_id_present
    validate_device_id_valid
    validate_modality_present
    return if modality_or_device_errors?

    validate_modality_matches
  end

  def validate_device_id_present
    unless @device_id.present?
      @device_errors << "device_id is missing"
    end
  end

  def validate_device_id_valid
    return if @device_errors.present?

    unless Device.exists?(id: @device_id) || DeviceResource.exists?(id: @device_id)
      @device_errors << "A device with id: #{@device_id} does not exist."
    end
  end

  def validate_modality_present
    unless @ie_modality.present?
      @modality_errors << "ie_modality is missing"
    end
  end

  def modality_or_device_errors?
    @modality_errors.present? || @device_errors.present?
  end

  def validate_modality_matches
    device_modality = @imaging_event.device.modality
    unless device_modality.include?(@ie_modality)
      @modality_errors << "Imaging Event modality \"#{@ie_modality}\" does not match parent device modality: #{device_modality.join(', ')}"
    end
  end

  def get_validation_values(imaging_event)
    @imaging_event = imaging_event
    @device_id = @imaging_event.device_id.first
    @device_errors = @imaging_event.errors[:device_id]
    @ie_modality = @imaging_event.ie_modality.first
    @modality_errors = @imaging_event.errors[:ie_modality]
  end
end

class ImagingEvent < Morphosource::Works::Base
  include ::Hyrax::WorkBehavior
  validates_with Morphosource::ParentChildValidator, ImagingEventParentDeviceModalityValidator
  before_create :controlled_value_filter, :date_filter
  before_update :controlled_value_filter, :date_filter
  after_save :add_id_to_title

  self.work_requires_files = false
  self.indexer = ImagingEventIndexer
  # Change this to restrict which works can be added as a child.
  self.valid_child_concerns = [Media, ProcessingEvent]

  validates :title, presence: { message: 'Your work must have a title.' }

  include Morphosource::ImagingEventMetadata

  # This must be included at the end, because it finalizes the metadata
  # schema (by adding accepts_nested_attributes)
  include ::Hyrax::BasicMetadata

  # Custom method to handle CarrierWave uploader
  def description_uploader
    @description_uploader ||= ImagingEventDescriptionAttachmentUploader.new.tap { |u| u.work_id = id }
  end

  # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached, or nil to delete the file
  def description_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.description_attachment_url.present?
      file_name = File.basename(self.description_attachment_url)
      description_uploader.retrieve_from_store!(file_name)
      if description_uploader.file.present? && File.exist?(description_uploader.file.path)
        Rails.logger.info "Deleting file: #{description_uploader.file.path}"
        description_uploader.remove!
      else
        Rails.logger.warn "File not found: #{description_uploader.file&.path}"
      end
      self.description_attachment_url = nil
      self.save
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if description_attachment_formats.include?(extension)
        description_uploader.store!(file)
        self.description_attachment_url = description_uploader.url
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
    end
  end

  def description_attachment
    self.description_attachment_url
  end

  def description_attachment_formats
    @description_attachment_formats ||= Morphosource.attachment_formats
  end

  def reference_uploader
    @reference_uploader ||= ImagingEventReferenceAttachmentUploader.new.tap { |u| u.work_id = id }
  end

  # @param file [File, ActionDispatch::Http::UploadedFile] The file to be attached, or nil to delete the file
  def reference_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.reference_attachment_url.present?
      file_name = File.basename(self.reference_attachment_url)
      reference_uploader.retrieve_from_store!(file_name)
      if reference_uploader.file.present? && File.exist?(reference_uploader.file.path)
        Rails.logger.info "Deleting file: #{reference_uploader.file.path}"
        reference_uploader.remove!
      else
        Rails.logger.warn "File not found: #{reference_uploader.file&.path}"
      end
      self.reference_attachment_url = nil
      self.save
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if reference_attachment_formats.include?(extension)
        reference_uploader.store!(file)
        self.reference_attachment_url = reference_uploader.url
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
    end
  end

  def reference_attachment
    self.reference_attachment_url
  end

  def reference_attachment_formats
    @reference_attachment_formats ||= Morphosource.reference_attachment_formats
  end

  def device
    DeviceResource.find(device_id.first)
  end

  def media
    descendants.select{ |d| d.media? }
  end

  def objects
    ActiveFedora::Base.find(Array(physical_object_id))
  end

  private

    def add_id_to_title
      unless self.title && self.id && self.title.first.to_s.start_with?("IE#{self.id.to_s}: ")
        self.title.set("IE#{self.id.to_s}: #{self.title.first.to_s}")
      end
    end

    def date_attributes_for_filter
      [ :date_created ]
    end

    def controlled_attributes
      {
        :pixel_spacing_calibration => Morphosource::PixelSpacingCalibrationService.new, 
        :target_type => Morphosource::TargetTypesService.new, 
        :detector_type => Morphosource::DetectorTypesService.new, 
        :detector_configuration => Morphosource::DetectorConfigurationService.new, 
        :acquisition_type => Morphosource::AcquisitionTypesService.new, 
        :focal_length_type => Morphosource::FocalLengthTypesService.new, 
        :light_source => Morphosource::LightSourceService.new
      }
    end

end
