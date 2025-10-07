# Add custom thumbnail to media with record locking and latest record query
class AddCustomThumbnailJob < Hyrax::ApplicationJob
  include Hyrax::Lockable

  queue_as Hyrax.config.ingest_queue_name

  # @param [String] media_id - the media work ID
  # @param [Array<Hyrax::UploadedFile>] custom_thumbnail - the uploaded thumbnail image
  def perform(media_id, custom_thumbnail)
    acquire_lock_for(media_id) do
      media = Media.find(media_id)
      Morphosource::MediaCustomThumbnailService.new(
        media: media,
        custom_thumbnail: custom_thumbnail
      ).create_thumbnail
    end
  end
end