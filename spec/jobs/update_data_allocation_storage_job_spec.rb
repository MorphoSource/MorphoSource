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

    context 'when fund code has no media' do
      it 'sets storage_current_gb to 0.0 without querying Solr' do
        expect_any_instance_of(Morphosource::SolrService).not_to receive(:get_docs)
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(0.0)
      end
    end

    context 'when fund code has media but no files characterized yet' do
      let(:media_id) { 'test000001' }

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id, active: true)
        # Solr returns a doc with nil all_files_file_size_lts (not yet characterized)
        allow_any_instance_of(Morphosource::SolrService).to receive(:get_docs)
          .and_return([{ 'id' => media_id, 'all_files_file_size_lts' => nil }])
      end

      it 'sets storage_current_gb to 0.0' do
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(0.0)
      end
    end

    context 'when fund code has multiple media with characterized files' do
      let(:media_id_1) { 'test000002' }
      let(:media_id_2) { 'test000003' }
      # 1 GiB each → expect 2.0 binary GB total
      let(:one_gib) { 1_073_741_824 }

      before do
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_1, active: true)
        FundCodeMediaAssociation.create!(fund_code: fund_code, media: media_id_2, active: true)
        allow_any_instance_of(Morphosource::SolrService).to receive(:get_docs)
          .and_return([
            { 'id' => media_id_1, 'all_files_file_size_lts' => one_gib },
            { 'id' => media_id_2, 'all_files_file_size_lts' => one_gib }
          ])
      end

      it 'sets storage_current_gb to the binary GB sum across all media' do
        described_class.perform_now(data_allocation)
        expect(data_allocation.reload.storage_current_gb).to eq(2.0)
      end
    end
  end
end
