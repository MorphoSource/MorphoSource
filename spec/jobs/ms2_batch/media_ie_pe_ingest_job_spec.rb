require 'rails_helper'

RSpec.describe BatchSubmissionJobs::Ms2Batch::MediaIePeIngestJob do
  subject(:job) { described_class.new }

  let(:media_ids) { %w[media-1 media-2] }
  let(:media) do
    [
      instance_double('Media', id: media_ids[0], organization_id: ['org-123']),
      instance_double('Media', id: media_ids[1], organization_id: ['org-123'])
    ]
  end

  before do
    ActiveJob::Base.queue_adapter = :test
    job.instance_variable_set(:@organization_id, 'org-123')
  end

  describe '#transfer_media_to_organization' do
    it 'enqueues transfer jobs when immediate transfer is enabled and org allows ownership transfer' do
      allow(SolrDocument).to receive(:find).with('org-123').and_return(
        { 'media_ownership_transfer_bsi' => true }
      )

      expect(TransferToOrganizationJob).to receive(:perform_later).with(media_ids[0])
      expect(TransferToOrganizationJob).to receive(:perform_later).with(media_ids[1])
      job.send(:transfer_media_to_organization, media, true)
    end

    it 'does not enqueue transfer jobs when org disallows ownership transfer' do
      allow(SolrDocument).to receive(:find).with('org-123').and_return(
        { 'media_ownership_transfer_bsi' => false }
      )

      expect(TransferToOrganizationJob).not_to receive(:perform_later)
      job.send(:transfer_media_to_organization, media, true)
    end

    it 'does not enqueue transfer jobs when immediate transfer is false' do
      expect(TransferToOrganizationJob).not_to receive(:perform_later)
      job.send(:transfer_media_to_organization, media, false)
    end
  end
end
