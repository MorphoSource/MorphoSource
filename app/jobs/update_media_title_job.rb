class UpdateMediaTitleJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_slow_queue_name

  # Update media title based on attributes part, media_type, and IE modality
  #
  # @param media_id [String]
  def perform(media_id)
    if Media.exists?(media_id)
      media = Media.find(media_id)
      media.title = [media.generate_title_from_attributes]
      media.save!
    end
  end
end