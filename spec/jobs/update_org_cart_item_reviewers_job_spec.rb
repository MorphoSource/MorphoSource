# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateOrgCartItemReviewersJob do
  subject(:job) { described_class.new }

  let(:org_id) { 'organization-id' }
  let(:org) { instance_double(OrganizationCollection) }

  it 'loads the organization from the serializable id argument' do
    allow(OrganizationCollection).to receive(:find).with(org_id).and_return(org)
    allow(job).to receive(:affected_media_ids).with(org).and_return([])

    job.perform(org_id)

    expect(OrganizationCollection).to have_received(:find).with(org_id)
  end

  describe 'reviewer resolution' do
    let(:media_id)    { 'media-1' }
    let(:requester)   { User.create!(email: 'requester@example.com', password: 'password') }
    let(:manager)     { User.create!(email: 'manager@example.com', password: 'password') }
    let!(:cart_item)  { CartItem.create!(user: requester, work_id: media_id, date_requested: Date.current) }
    let(:reviewer_org) { instance_double(OrganizationCollection, id: org_id) }

    before do
      allow(OrganizationCollection).to receive(:find).with(org_id).and_return(org)
      allow(job).to receive(:affected_media_ids).with(org).and_return([media_id])
    end

    context 'when the org is the explicit download_reviewer on the media' do
      before do
        allow(ActiveFedora::SolrService).to receive(:query).and_return([
          { 'id' => media_id, 'download_reviewer_ssim' => [org_id], 'user_with_ownership_ssi' => nil }
        ])
        allow(User).to receive(:where).with(ms_id: [org_id]).and_return([])
        allow(OrganizationCollection).to receive(:where).with(id: [org_id]).and_return([reviewer_org])
        allow(reviewer_org).to receive(:media_download_reviewers).and_return([manager.ms_id])
      end

      it 'sets cart_item reviewers to the resolved manager ms_ids' do
        expect { job.perform(org_id) }
          .to change { cart_item.reload.reviewers }
          .to([manager.ms_id])
      end
    end

    context 'when the org is the media owner with no download_reviewer configured' do
      before do
        allow(ActiveFedora::SolrService).to receive(:query).and_return([
          { 'id' => media_id, 'download_reviewer_ssim' => nil, 'user_with_ownership_ssi' => org_id }
        ])
        allow(User).to receive(:where).with(ms_id: [org_id]).and_return([])
        allow(OrganizationCollection).to receive(:where).with(id: [org_id]).and_return([reviewer_org])
        allow(reviewer_org).to receive(:media_download_reviewers).and_return([manager.ms_id])
      end

      it 'sets cart_item reviewers to the org manager ms_ids' do
        expect { job.perform(org_id) }
          .to change { cart_item.reload.reviewers }
          .to([manager.ms_id])
      end
    end
  end
end
