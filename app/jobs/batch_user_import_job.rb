class BatchUserImportJob < ApplicationJob

  queue_as Hyrax.config.ingest_queue_name

  def perform(attributes)
    u = User.new(attributes)
    u.validate!
    u.save!
  end

end