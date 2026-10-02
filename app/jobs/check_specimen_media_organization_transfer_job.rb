# Transfers or redirects a specimen/CHO's media to its new organization after the organization changed.
class CheckSpecimenMediaOrganizationTransferJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.update_fast_queue_name

  # @param [String] specimen_id - the BiologicalSpecimen/CulturalHeritageObject ID
  # @param [String] old_organization_id - the OrganizationCollection ID the specimen was previously assigned to
  # @param [String] new_organization_id - the OrganizationCollection ID the specimen is now assigned to
  def perform(specimen_id, old_organization_id, new_organization_id)
    specimen = ActiveFedora::Base.find(specimen_id)
    specimen.media.each do |m|
      if m.pending_org_transfer
        TransferToOrganizationJob.perform_later(m.id, organization_id: new_organization_id, force_update: true)
      elsif m.user_with_ownership == old_organization_id
        TransferToOrganizationJob.perform_later(m.id, organization_id: new_organization_id)
      end
    end
  end
end
