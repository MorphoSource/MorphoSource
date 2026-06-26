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

  describe 'ancestor_org_ids' do
    let(:parent_org_id) { 'parent-org-id' }
    let(:grandparent_org_id) { 'grandparent-org-id' }

    def solr_org_query_for(id)
      satisfy { |q| q.include?("has_model_ssim:OrganizationCollection") && q.include?("download_reviewer_ssim:#{RSolr.solr_escape(id)}") }
    end

    it 'returns ids of orgs that list the given org as a download_reviewer' do
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(org_id), anything).and_return([{ 'id' => parent_org_id }])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(parent_org_id), anything).and_return([])

      expect(job.send(:ancestor_org_ids, org_id)).to eq([parent_org_id])
    end

    it 'discovers ancestors recursively' do
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(org_id), anything).and_return([{ 'id' => parent_org_id }])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(parent_org_id), anything).and_return([{ 'id' => grandparent_org_id }])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(grandparent_org_id), anything).and_return([])

      expect(job.send(:ancestor_org_ids, org_id)).to contain_exactly(parent_org_id, grandparent_org_id)
    end

    it 'handles cycles without looping' do
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(org_id), anything).and_return([{ 'id' => parent_org_id }])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(solr_org_query_for(parent_org_id), anything).and_return([{ 'id' => org_id }])

      expect { job.send(:ancestor_org_ids, org_id) }.not_to raise_error
    end
  end

  describe 'reviewer resolution' do
    let(:media_id)     { 'media-1' }
    let!(:requester)   { User.create!(email: 'requester@example.com', password: 'password') }
    let!(:manager)     { User.create!(email: 'manager@example.com', password: 'password') }
    let!(:cart_item)   { CartItem.create!(user: requester, work_id: media_id, date_requested: Date.current) }
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
