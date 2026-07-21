# Transfers a single media's ownership to a specific organization, triggered by a
# specimen/CHO's organization_id changing. Distinct from TransferToOrganizationJob
# (driven by media visibility changing to open + organization_transfer_on_publish)
# because here the target organization is already known precisely from the specimen
# callback and must not be re-derived from Media#organizations (an ancestor aggregate).
class TransferSpecimenMediaToOrganizationJob < Hyrax::ApplicationJob
  include Hyrax::Lockable

  queue_as Hyrax.config.ingest_queue_name

  # @param [String] media_id - the media work ID
  # @param [String] organization_id - the OrganizationCollection ID to transfer to
  def perform(media_id, organization_id)
    acquire_lock_for(media_id) do
      media = Media.find(media_id)
      organization = OrganizationCollection.find(organization_id)
      media.transfer_media_to_organization_collection(organization)
    end
  end
end
