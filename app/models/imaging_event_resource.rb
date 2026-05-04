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

    device_found = begin
      Hyrax.query_service.find_by(id: @device_id)
      true
    rescue Valkyrie::Persistence::ObjectNotFoundError
      false
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

  # Mirrors ImagingEvent class attributes from Morphosource::Works::Base.
  # AF uses class_attribute which provides both class and instance accessors
  # automatically; Valkyrie resources must define them explicitly.

  # Mirrors ImagingEvent.valid_child_concerns; used by Hyrax::ChildWorkRedirect.
  # ToDoValk: update when Media and ProcessingEvent are valkyrized.
  def self.valid_child_concerns
    [Media, ProcessingEvent]
  end

  def valid_child_concerns
    self.class.valid_child_concerns
  end

  # Mirrors ImagingEvent.valid_parent_concerns (returns []); used by
  # valid_work_types_list helper in the form relationships view.
  def self.valid_parent_concerns
    []
  end

  def valid_parent_concerns
    self.class.valid_parent_concerns
  end

  # Mirrors ImagingEvent.work_requires_files (false); used by files_required? helper.
  def self.work_requires_files?
    false
  end

  def work_requires_files?
    self.class.work_requires_files?
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

  def device
    return nil unless device_id.first.present?
    Hyrax.query_service.find_by(id: device_id.first)
  end

  def media
    media_descendants(self)
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

  private

    def media_descendants(object)
      child_works_for(object).flat_map do |child|
        child_media = child.is_a?(Media) ? [child] : []
        child_media + media_descendants(child)
      end.uniq { |work| work.id.to_s }
    end

    def child_works_for(object)
      if object.respond_to?(:members)
        object.members
      elsif object.respond_to?(:member_ids) && object.member_ids.present?
        ActiveFedora::Base.find(object.member_ids)
      else
        []
      end
    rescue ::ActiveFedora::ObjectNotFoundError, Ldp::Gone, Valkyrie::Persistence::ObjectNotFoundError
      []
    end

end
