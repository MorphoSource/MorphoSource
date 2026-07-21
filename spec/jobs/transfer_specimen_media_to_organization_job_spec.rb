require 'rails_helper'

RSpec.describe TransferSpecimenMediaToOrganizationJob do
  let(:depositor)               { create(:user) }
  let(:organization_depositor)  { User.create(email: 'org_depositor@email.com', password: 'password') }
  let!(:contributor_role)       { Role.create(name: 'contributor') }
  let!(:organization)           { FactoryBot.create(:organization_collection, depositor: organization_depositor.ms_id, media_ownership_transfer: true) }
  let(:media)                   { Media.create(title: ['media'], depositor: depositor.ms_id, visibility: 'restricted', fileset_accessibility: ['private']) }

  before do
    organization_depositor.make_contributor
    organization.managers << organization_depositor
    organization.managers_group.save
  end

  it 'creates a pending organization transfer for the given media and organization' do
    described_class.perform_now(media.id, organization.id)
    transfer = ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, organization_transfer: true).first
    expect(transfer).to be_present
  end

  it 'sets pending_org_transfer to true on the media' do
    described_class.perform_now(media.id, organization.id)
    expect(Media.find(media.id).pending_org_transfer).to eq(true)
  end
end
