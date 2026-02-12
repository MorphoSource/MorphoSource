# frozen_string_literal: true

class UpdateWorkArkStatusJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # Update ARK status for an existing work.
  #
  # @param work_id [String]
  def perform(work_id)
    resource = find_resource(work_id)
    return unless resource.is_a?(DeviceResource)
    return if resource.ark.blank?

    resource.update_ark_status
  end

  private

  def find_resource(work_id)
    Hyrax.query_service.find_by(id: work_id)
  rescue Valkyrie::Persistence::ObjectNotFoundError
    nil
  end
end
