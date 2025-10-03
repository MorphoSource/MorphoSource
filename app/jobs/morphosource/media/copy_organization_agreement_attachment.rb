# Copy agreement attachment from organization to media with record locking and latest record query
class Morphosource::Media::CopyOrganizationAgreementAttachmentJob < Hyrax::ApplicationJob
  include Hyrax::Lockable

  queue_as Hyrax.config.ingest_queue_name

  # @param [String] media_id - the media work ID
  # @param [String] organization_id - ID for organization work or organization collection
  def perform(media_id, organization_id)
    acquire_lock_for(media_id) do
      organization = (
        ::Organization.find_by(id: organization_id) || ::OrganizationCollection.find_by(id: organization_id)
      )
      media = ::Media.find(media_id)
      media.copy_organization_agreement_attachment(organization)
    end
  end
end