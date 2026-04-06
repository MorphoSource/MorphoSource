# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource ImagingEventResource`

class ImagingEventResourceParentDeviceModalityValidator < ActiveModel::Validator

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

    # Use postgres_service + explicit AF fallback rather than
    # Hyrax.query_service.find_by, because Wings does not reliably find AF
    # objects for models not registered in Wings::ModelRegistry (e.g. Device).
    # This mirrors the pattern in Morphosource::ArResourceMembership#members.
    device_found = begin
      Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(@device_id))
      true
    rescue Valkyrie::Persistence::ObjectNotFoundError
      begin
        ActiveFedora::Base.find(@device_id)
        true
      rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
        false
      end
    end

    unless device_found
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

class ImagingEventResource < Hyrax::Work
  include Hyrax::Schema(:basic_metadata)
  include Hyrax::Schema(:imaging_event_resource)
  include Morphosource::ValkyrieWorkBehavior
  include ActiveModel::Validations

  delegate :download_groups, :download_groups=,
           :download_users,  :download_users=, to: :permission_manager

  # ToDoValk: Morphosource::ParentChildValidator uses record.works and
  # record.valid_child_concerns which are not available on Valkyrie resources.
  validates_with ImagingEventResourceParentDeviceModalityValidator

  # Mirrors ImagingEvent.valid_child_concerns; used by Hyrax::ChildWorkRedirect.
  # ToDoValk: update when Media and ProcessingEvent are valkyrized.
  def self.valid_child_concerns
    [Media, ProcessingEvent]
  end

  def imaging_event?
    true
  end

  def media?
    false
  end

  def physical_object?
    false
  end

  def file_sets
    []
  end

  def description_uploader
    @description_uploader ||= ImagingEventDescriptionAttachmentUploader.new.tap { |u| u.work_id = id.to_s }
  end

  def description_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.description_attachment_url.present?
      file_name = File.basename(self.description_attachment_url.first)
      description_uploader.retrieve_from_store!(file_name)
      if description_uploader.file.present? && File.exist?(description_uploader.file.path)
        Rails.logger.info "Deleting file: #{description_uploader.file.path}"
        description_uploader.remove!
      else
        Rails.logger.warn "File not found: #{description_uploader.file&.path}"
      end
      self.description_attachment_url = []
      self.save
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if description_attachment_formats.include?(extension)
        description_uploader.store!(file)
        self.description_attachment_url = [description_uploader.url]
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
    end
  end

  def description_attachment
    self.description_attachment_url.first
  end

  def description_attachment_formats
    @description_attachment_formats ||= Morphosource.attachment_formats
  end

  def reference_uploader
    @reference_uploader ||= ImagingEventReferenceAttachmentUploader.new.tap { |u| u.work_id = id.to_s }
  end

  def reference_attachment=(file)
    if file.nil?
      # delete attachment
      return unless self.reference_attachment_url.present?
      file_name = File.basename(self.reference_attachment_url.first)
      reference_uploader.retrieve_from_store!(file_name)
      if reference_uploader.file.present? && File.exist?(reference_uploader.file.path)
        Rails.logger.info "Deleting file: #{reference_uploader.file.path}"
        reference_uploader.remove!
      else
        Rails.logger.warn "File not found: #{reference_uploader.file&.path}"
      end
      self.reference_attachment_url = []
      self.save
    else
      # add attachment
      extension = File.extname(file.original_filename).downcase
      if reference_attachment_formats.include?(extension)
        reference_uploader.store!(file)
        self.reference_attachment_url = [reference_uploader.url]
        self.save
      else
        raise ArgumentError, "Invalid file format: #{extension}"
      end
    end
  end

  def reference_attachment
    self.reference_attachment_url.first
  end

  def reference_attachment_formats
    @reference_attachment_formats ||= Morphosource.reference_attachment_formats
  end

  # Use postgres_service + explicit AF fallback rather than
  # Hyrax.query_service.find_by, because Wings does not reliably find AF
  # objects for models not registered in Wings::ModelRegistry (e.g. Device).
  # This mirrors the pattern in Morphosource::ArResourceMembership#members.
  def device
    Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(device_id.first))
  rescue Valkyrie::Persistence::ObjectNotFoundError
    ActiveFedora::Base.find(device_id.first)
  end

  # ToDoValk: only checks direct members; should recurse into descendants like
  # ImagingEvent#media does. Update when descendant traversal is supported for
  # Valkyrie resources.
  def media
    members.select { |m| m.is_a?(Media) || ('MediaResource'.safe_constantize && m.is_a?('MediaResource'.safe_constantize)) }
  end

  # Use postgres_service + explicit AF fallback rather than
  # Hyrax.query_service.find_by, because Wings does not reliably find AF
  # objects for models not registered in Wings::ModelRegistry.
  # This mirrors the pattern in Morphosource::ArResourceMembership#members.
  def objects
    Array(physical_object_id).filter_map do |id|
      Hyrax.query_service.postgres_service.find_by(id: Valkyrie::ID.new(id))
    rescue Valkyrie::Persistence::ObjectNotFoundError
      begin
        ActiveFedora::Base.find(id)
      rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone
        nil
      end
    end
  end

  # Valkyrie does not support AR-style before_create/before_update/after_save
  # callbacks. We override save to run the filters before persisting and to
  # apply the IE prefix post-persist (the id is not available until after the
  # persister runs). The second save for the title prefix only occurs when the
  # prefix is absent (i.e. on first save or if the prefix was somehow lost).
  def save(**opts)
    controlled_value_filter
    date_filter
    result = super
    return result unless result
    unless title.first.to_s.start_with?("IE#{id}: ")
      add_id_to_title
      result = Hyrax.persister.save(resource: self)
      Hyrax.index_adapter.save(resource: result)
    end
    result
  end

  def needs_id_title_prefix?
    !title.first.to_s.start_with?("IE#{id}: ")
  end

  def apply_id_title_prefix
    self.title = ["IE#{id}: #{title.first.to_s}"]
  end

  private

    def add_id_to_title
      apply_id_title_prefix
    end

    def controlled_value_filter
      controlled_attributes.each do |attr, service|
        self.send(attr.to_s+"=", self.send(attr).collect { |e| e ? service.controlled_value(e.strip) : e })
      end
    end

    # Valkyrie resources do not support _changed? dirty tracking, so the date
    # format is applied unconditionally (the operation is idempotent).
    def date_filter
      date_attributes_for_filter.each do |attr|
        str = self.send(attr)&.first
        case str
        when /^(\d{4})[\-\/](\d{1,2})[\-\/](\d{1,2})$/
          str = $1 + "-" + $2.rjust(2, "0") + "-" + $3.rjust(2, "0") if Date.valid_date? $1.to_i, $2.to_i, $3.to_i
        when /^(\d{1,2})[\-\/](\d{1,2})[\-\/](\d{4})$/
          str = $3 + "-" + $1.rjust(2, "0") + "-" + $2.rjust(2, "0") if Date.valid_date? $3.to_i, $1.to_i, $2.to_i
        when nil
          str = ''
        else
          # leave str as it is
        end
        self.send(attr.to_s+"=", [str])
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
