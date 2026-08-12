require 'rails_helper'

RSpec.describe CheckSpecimenMediaOrganizationTransferJob do
  let(:old_org)       { FactoryBot.create(:organization_collection, title: ['old org']) }
  let(:new_org)       { FactoryBot.create(:organization_collection, title: ['new org']) }
  let(:specimen)      { FactoryBot.create(:biological_specimen) }
  let(:owned_media)   { instance_double(Media, id: 'owned-media-id', user_with_ownership: old_org.id) }
  let(:unowned_media) { instance_double(Media, id: 'unowned-media-id', user_with_ownership: 'someone-else') }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(ActiveFedora::Base).to receive(:find).with(specimen.id).and_return(specimen)
    allow(specimen).to receive(:media).and_return([owned_media, unowned_media])
  end

  it 'enqueues a transfer job only for media currently owned by the old organization' do
    described_class.perform_now(specimen.id, old_org.id, new_org.id)
    expect(TransferToOrganizationJob).to have_been_enqueued.with('owned-media-id', organization_id: new_org.id)
    expect(TransferToOrganizationJob).not_to have_been_enqueued.with('unowned-media-id', organization_id: new_org.id)
  end
end
