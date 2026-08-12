# Transfer media to organization with record locking and latest record query
class TransferToOrganizationJob < Hyrax::ApplicationJob
  include Hyrax::Lockable

  queue_as Hyrax.config.ingest_queue_name

  # @param [String] media_id - the media work ID
  # @param [String, nil] organization_id - explicit OrganizationCollection ID to transfer to; when omitted, derives the organization from the media's physical objects
  def perform(media_id, organization_id: nil)
    acquire_lock_for(media_id) do
      media = Media.find(media_id)
      if organization_id
        media.transfer_media_to_organization_collection(OrganizationCollection.find(organization_id))
      else
        media.transfer_media_to_organization
      end
    end
  end
end