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

  describe '#organization_allows_media_ownership_transfer?' do
    context 'when org_id is not present' do
      before { job.instance_variable_set(:@organization_id, nil) }

      let(:media_without_org) do
        [instance_double('Media', id: 'media-1', organization_id: [])]
      end

      it 'returns false' do
        expect(job.send(:organization_allows_media_ownership_transfer?, media_without_org)).to be false
      end
    end

    context 'when SolrDocument is not found' do
      before { allow(SolrDocument).to receive(:find).with('org-123').and_return(nil) }

      it 'returns false' do
        expect(job.send(:organization_allows_media_ownership_transfer?, media)).to be false
      end
    end

    context 'when the org is a legacy Organization' do
      let(:org_doc) { instance_double(SolrDocument, organization?: true) }

      before { allow(SolrDocument).to receive(:find).with('org-123').and_return(org_doc) }

      it 'returns true when a data manager is present' do
        allow(org_doc).to receive(:[]).with('data_manager_tesim').and_return(['manager@example.com'])
        expect(job.send(:organization_allows_media_ownership_transfer?, media)).to be true
      end

      it 'returns false when no data manager is present' do
        allow(org_doc).to receive(:[]).with('data_manager_tesim').and_return(nil)
        expect(job.send(:organization_allows_media_ownership_transfer?, media)).to be false
      end
    end

    context 'when the org is an OrganizationCollection' do
      let(:org_doc) { instance_double(SolrDocument, organization?: false) }

      before { allow(SolrDocument).to receive(:find).with('org-123').and_return(org_doc) }

      it 'returns true when media_ownership_transfer is enabled' do
        allow(org_doc).to receive(:[]).with('media_ownership_transfer_bsi').and_return(true)
        expect(job.send(:organization_allows_media_ownership_transfer?, media)).to be true
      end

      it 'returns false when media_ownership_transfer is disabled' do
        allow(org_doc).to receive(:[]).with('media_ownership_transfer_bsi').and_return(false)
        expect(job.send(:organization_allows_media_ownership_transfer?, media)).to be false
      end
    end
  end

  describe '#transfer_media_to_organization' do
    let(:org_doc) { instance_double(SolrDocument, organization?: false) }

    before { allow(SolrDocument).to receive(:find).with('org-123').and_return(org_doc) }

    it 'enqueues transfer jobs when immediate transfer is enabled and org allows ownership transfer' do
      allow(org_doc).to receive(:[]).with('media_ownership_transfer_bsi').and_return(true)

      expect(TransferToOrganizationJob).to receive(:perform_later).with(media_ids[0])
      expect(TransferToOrganizationJob).to receive(:perform_later).with(media_ids[1])
      job.send(:transfer_media_to_organization, media, true)
    end

    it 'does not enqueue transfer jobs when org disallows ownership transfer' do
      allow(org_doc).to receive(:[]).with('media_ownership_transfer_bsi').and_return(false)

      expect(TransferToOrganizationJob).not_to receive(:perform_later)
      job.send(:transfer_media_to_organization, media, true)
    end

    it 'does not enqueue transfer jobs when immediate transfer is false' do
      expect(TransferToOrganizationJob).not_to receive(:perform_later)
      job.send(:transfer_media_to_organization, media, false)
    end
  end
end
