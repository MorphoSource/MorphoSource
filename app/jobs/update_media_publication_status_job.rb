class UpdateMediaPublicationStatusJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # Update media publication status with status code (one of "open", "restricted", "private")
  #
  # @param media_id [String]
  # @param status [String] new publication status code (one of "open", "restricted", "private")
  def perform(media_id, status)
    if Media.exists?(media_id)
      media = Media.find(media_id)
      media.update_publication_status(status)
    end
  end
end