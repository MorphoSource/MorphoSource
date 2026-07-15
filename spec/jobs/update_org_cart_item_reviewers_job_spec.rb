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
