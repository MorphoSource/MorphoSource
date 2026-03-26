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

    begin
      Hyrax.query_service.find_by(id: Valkyrie::ID.new(@device_id))
    rescue Valkyrie::Persistence::ObjectNotFoundError
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


end
