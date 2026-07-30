class UpdateMediaMetadataJob < UpdateWorkMetadataJob

  queue_as Hyrax.config.update_slow_queue_name

end
