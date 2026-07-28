class UpdateWorkMetadataJob < Hyrax::ApplicationJob

  queue_as Hyrax.config.update_medium_queue_name

  # System/structural attributes that must never be mass-assigned through
  # these jobs, even though they appear in the record's #attributes.
  PROTECTED_PROPERTIES = %w[
    id head tail access_control_id admin_set_id arkivo_checksum
    date_modified date_uploaded embargo_id lease_id proxy_depositor
    rendering_ids state
  ].freeze

  def perform(work_attributes, skip_index_related_works: false, allow_blank_values: false)
    work = find_record(work_attributes)
    return unless work

    assign_attributes(work, work_attributes, allow_blank_values: allow_blank_values)
    work.skip_index_related_works = true if skip_index_related_works
    work.save!
  end

  protected

  # The id may arrive bare (e.g. "abc123") or wrapped in an array
  # (e.g. ["abc123"]); accept either form.
  def find_record(attributes)
    id = Array.wrap(attributes[:id]).first
    return nil unless id && ::ActiveFedora::Base.exists?(id)
    ::ActiveFedora::Base.find(id)
  end

  def assign_attributes(record, attributes, allow_blank_values: false)
    assignable_properties(record).each do |property|
      next unless attributes.key?(property)
      value = attributes[property]
      next if !allow_blank_values && blank_value?(value)
      next if record.public_send(property) == value
      record.public_send("#{property}=", value)
    end
  end

  # false is a legitimate value for boolean attributes and must not be
  # treated as blank the way nil/""/[] are (false.present? is false).
  def blank_value?(value)
    value != false && value.blank?
  end

  def assignable_properties(record)
    record.attributes.keys.map(&:to_sym) - self.class::PROTECTED_PROPERTIES.map(&:to_sym)
  end

end
