# Transfer media to organization with record locking and latest record query
class Morphosource::Media::TransferToOrganizationJob < Hyrax::ApplicationJob
  include Hyrax::Lockable

  queue_as Hyrax.config.ingest_queue_name

  # @param [String] media_id - the media work ID
  def perform(media_id)
    acquire_lock_for(media_id) do
      media = Media.find(media_id)
      media.transfer_media_to_organization
    end
  end
end