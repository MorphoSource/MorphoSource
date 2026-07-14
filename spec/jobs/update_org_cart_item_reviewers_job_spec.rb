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
      satisfy { |q| q.include?("has_model_ssim:OrganizationCollection") && q.include?("download_reviewer_ssim:#{RSolr.solr_escape("org_collection:#{id}")}") }
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

  describe 'fan-out' do
    before do
      allow(OrganizationCollection).to receive(:find).with(org_id).and_return(org)
      allow(job).to receive(:affected_media_ids).with(org).and_return(['media-1', 'media-2'])
      allow(UpdateCartItemReviewersJob).to receive(:perform_later)
    end

    it 'enqueues UpdateCartItemReviewersJob for each affected media' do
      job.perform(org_id)

      expect(UpdateCartItemReviewersJob).to have_received(:perform_later).with('media-1')
      expect(UpdateCartItemReviewersJob).to have_received(:perform_later).with('media-2')
    end
  end

  describe 'affected_media_ids' do
    let(:org_with_id) { instance_double(OrganizationCollection, id: org_id) }

    it 'finds media referencing the org as download_reviewer or owner, without duplicates' do
      allow(job).to receive(:ancestor_org_ids).with(org_id).and_return([])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(satisfy { |q| q.include?("download_reviewer_ssim:#{RSolr.solr_escape("org_collection:#{org_id}")}") }, anything)
        .and_return([{ 'id' => 'media-1' }])
      allow(ActiveFedora::SolrService).to receive(:query)
        .with(satisfy { |q| q.include?("user_with_ownership_ssi:#{RSolr.solr_escape(org_id)}") }, anything)
        .and_return([{ 'id' => 'media-1' }, { 'id' => 'media-2' }])

      expect(job.send(:affected_media_ids, org_with_id)).to contain_exactly('media-1', 'media-2')
    end
  end
end
