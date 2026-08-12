require 'rails_helper'

RSpec.describe CheckSpecimenMediaOrganizationTransferJob do
  let(:old_org)  { FactoryBot.create(:organization_collection, title: ['old org']) }
  let(:new_org)  { FactoryBot.create(:organization_collection, title: ['new org']) }
  let(:specimen) { FactoryBot.create(:biological_specimen) }

  let(:owned_media) do
    instance_double(Media, id: 'owned-media-id', user_with_ownership: old_org.id, pending_org_transfer: false)
  end
  let(:unowned_media) do
    instance_double(Media, id: 'unowned-media-id', user_with_ownership: 'someone-else', pending_org_transfer: false)
  end
  let(:pending_transfer_media) do
    instance_double(Media, id: 'pending-media-id', user_with_ownership: 'someone-else', pending_org_transfer: true)
  end

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(ActiveFedora::Base).to receive(:find).with(specimen.id).and_return(specimen)
  end

  context 'media currently owned by the old organization' do
    before { allow(specimen).to receive(:media).and_return([owned_media, unowned_media]) }

    it 'enqueues a transfer job only for the owned media' do
      described_class.perform_now(specimen.id, old_org.id, new_org.id)
      expect(TransferToOrganizationJob).to have_been_enqueued.with('owned-media-id', organization_id: new_org.id)
      expect(TransferToOrganizationJob).not_to have_been_enqueued.with('unowned-media-id', organization_id: new_org.id)
    end
  end

  context 'media with an existing pending organization transfer, not owned by the old organization' do
    before { allow(specimen).to receive(:media).and_return([pending_transfer_media]) }

    it 'force-redirects the pending transfer to the new organization instead of enqueuing a new transfer job' do
      expect(pending_transfer_media).to receive(:create_new_organization_transfer_request).with(new_org, true)
      expect(pending_transfer_media).to receive(:save!)
      described_class.perform_now(specimen.id, old_org.id, new_org.id)
      expect(TransferToOrganizationJob).not_to have_been_enqueued
    end
  end
end
