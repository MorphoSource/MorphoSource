require 'rails_helper'

RSpec.describe UpdateDataAllocationStorageJob do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    let(:user) { User.create!(email: 'fc_owner@example.com', password: 'password') }
    # FundCode.create! triggers after_create :create_data_allocation_if_needed
    let(:fund_code) { FundCode.create!(user: user, storage_total_gb: 100) }
    let(:data_allocation) { fund_code.data_allocation }

    context 'when allocation_type is :user' do
      # DataAllocation.belongs_to :fund_code is optional, so a standalone user-type record is valid
      let(:user_allocation) { DataAllocation.create!(allocation_type: :user) }

      it 'raises with "not yet supported"' do
        expect { described_class.perform_now(user_allocation) }
          .to raise_error(RuntimeError, /not yet supported/)
      end
    end

    context 'when fund_code is nil (orphaned DataAllocation)' do
      let(:orphaned_allocation) { DataAllocation.create!(allocation_type: :fund_code) }

      it 'raises with a clear message' do
        expect { described_class.perform_now(orphaned_allocation) }
          .to raise_error(RuntimeError, /fund_code is nil/)
      end
    end

    context 'when fund code has no media' do
      it 'sets storage_current_gb to 0.0 without querying Solr' do
        expect(Morphosource::SolrService).not_to receive(:new)
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(0.0)
      end
    end

    context 'when fund code has media but no files characterized yet' do
      let(:media_id) { 'test000001' }
      let(:solr_service) { double(get_docs: [{ 'id' => media_id, 'all_files_file_size_lts' => nil }]) }

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id, active: true)
        # Solr returns a doc with nil all_files_file_size_lts (not yet characterized)
        allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)
      end

      it 'sets storage_current_gb to 0.0' do
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(0.0)
      end
    end

    context 'when fund code has some media characterized and some not' do
      let(:media_id_1) { 'test000004' }
      let(:media_id_2) { 'test000005' }
      let(:one_gib) { 1_073_741_824 }
      let(:solr_service) do
        double(get_docs: [
          { 'id' => media_id_1, 'all_files_file_size_lts' => one_gib },
          { 'id' => media_id_2, 'all_files_file_size_lts' => nil }
        ])
      end

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_1, active: true)
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_2, active: true)
        allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)
      end

      it 'sums only the characterized media, ignoring nil values' do
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(1.0)
      end
    end

    context 'when media_ids exceed BATCH_SIZE' do
      let(:batch_size) { UpdateDataAllocationStorageJob::BATCH_SIZE }
      # One full batch plus one overflow — forces exactly two Solr queries
      let(:all_media_ids) { (1..(batch_size + 1)).map { |i| "test#{i}" } }
      let(:one_gib) { 1_073_741_824 }
      let(:solr_service) { double('SolrService') }

      before do
        # Stub the AR chain so we don't insert thousands of records
        assoc = double('fund_code_media_associations')
        allow(data_allocation.fund_code).to receive(:fund_code_media_associations).and_return(assoc)
        allow(assoc).to receive(:where).with(active: true).and_return(assoc)
        allow(assoc).to receive(:pluck).with(:media).and_return(all_media_ids)

        allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)
        # First call returns batch_size docs at 1 GiB each; second returns one doc at 1 GiB
        allow(solr_service).to receive(:get_docs)
          .and_return(
            [{ 'id' => 'batch_doc_1', 'all_files_file_size_lts' => one_gib * batch_size }],
            [{ 'id' => 'batch_doc_2', 'all_files_file_size_lts' => one_gib }]
          )
      end

      it 'queries Solr in batches and accumulates the total across all batches' do
        described_class.perform_now(data_allocation)
        expect(solr_service).to have_received(:get_docs).twice
        expect(data_allocation.reload.storage_current_gb).to eq(batch_size + 1.0)
      end
    end

    context 'when fund code has multiple media with characterized files' do
      let(:media_id_1) { 'test000002' }
      let(:media_id_2) { 'test000003' }
      # 1 GiB each → expect 2.0 binary GB total
      let(:one_gib) { 1_073_741_824 }
      let(:solr_service) do
        double(get_docs: [
          { 'id' => media_id_1, 'all_files_file_size_lts' => one_gib },
          { 'id' => media_id_2, 'all_files_file_size_lts' => one_gib }
        ])
      end

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_1, active: true)
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_2, active: true)
        allow(Morphosource::SolrService).to receive(:new).and_return(solr_service)
      end

      it 'sets storage_current_gb to the binary GB sum across all media' do
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(2.0)
      end
    end
  end
end
