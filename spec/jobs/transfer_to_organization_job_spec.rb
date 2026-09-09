require 'rails_helper'

RSpec.describe TransferToOrganizationJob do
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

  context 'organization_id is given explicitly' do
    it 'creates a pending organization transfer for the given organization' do
      described_class.perform_now(media.id, organization_id: organization.id)
      transfer = ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, organization_transfer: true).first
      expect(transfer).to be_present
    end
  end

  context 'organization_id is not given' do
    before { allow_any_instance_of(Media).to receive(:organizations).and_return([organization]) }

    it 'derives the organization from the media\'s physical objects' do
      described_class.perform_now(media.id)
      transfer = ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, organization_transfer: true).first
      expect(transfer).to be_present
    end
  end

  context 'force_update is true and the media already has a pending organization transfer' do
    let!(:old_organization) { FactoryBot.create(:organization_collection, title: ['old org']) }

    before do
      media.create_new_organization_transfer_request(old_organization)
      media.save!
    end

    it 'force-cancels the existing pending transfer and creates a new one for the given organization' do
      described_class.perform_now(media.id, organization_id: organization.id, force_update: true)
      old_transfer = ProxyDepositRequest.where(work_id: media.id, receiving_user: old_organization.id).first
      new_transfer = ProxyDepositRequest.where(work_id: media.id, receiving_user: organization.id, status: 'pending').first
      expect(old_transfer.status).to eq('canceled')
      expect(new_transfer).to be_present
    end
  end
end
