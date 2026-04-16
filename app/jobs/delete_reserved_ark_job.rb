# frozen_string_literal: true

class DeleteReservedArkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # @param ark [String]
  def perform(ark)
    identifier = Ezid::Identifier.find(ark)
    return unless identifier.status == 'reserved'

    identifier.delete
  rescue StandardError => e
    Rails.logger.error("Error deleting reserved ARK #{ark}: #{e.message}")
  end
end
