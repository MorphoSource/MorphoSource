require 'rails_helper'

RSpec.describe Morphosource::FundCodes::FundCodeChargeService do
  let(:user) { User.create!(email: 'test@example.com', password: 'password') }
  let(:fund_code) do
    FundCode.create!(
      title: 'Test FC',
      identifier: 'TESTFC',
      description: 'Test fund code',
      total: 1000.to_d,
      chargeable: true,
      user: user
    )
  end

  let(:media_id)   { 'test_media_001' }
  let(:fileset_id) { 'test_fileset_001' }
  let(:start_date) { Date.new(2026, 3, 25) }
  let(:end_date)   { Date.new(2026, 4, 27) }

  # Service instance with fixed dates to avoid auto-calculated billing window edge cases
  let(:service) do
    described_class.new(
      fund_code: fund_code,
      billing_rate: 1,
      billing_unit: 'gb',
      custom_start_date: start_date,
      custom_end_date: end_date
    )
  end

  before do
    allow(fund_code).to receive(:media_ids).and_return([media_id])

    # Stub Solr so tests don't require a running Solr instance
    solr_double = instance_double(Morphosource::SolrService)
    allow(Morphosource::SolrService).to receive(:new).and_return(solr_double)
    allow(solr_double).to receive(:get_docs).and_return(media_solr_docs)
    allow(service).to receive(:solr).and_return(solr_double)
  end

  describe '#query_media_fileset_ids' do
    context 'when the fund code has active media' do
      let(:media_solr_docs) do
        [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => 5_000_000 }]
      end

      it 'caches media_docs with all_files_file_size_lts so query_media_sizes avoids a second Solr round-trip' do
        service.query_media_fileset_ids
        expect(service.media_docs.first['all_files_file_size_lts']).to eq(5_000_000)
      end
    end

    context 'when the fund code has no active media' do
      before { allow(fund_code).to receive(:media_ids).and_return([]) }

      let(:media_solr_docs) { [] }

      it 'sets filesets_to_media to an empty hash and media_ids to an empty array' do
        service.query_media_fileset_ids
        expect(service.filesets_to_media).to eq({})
        expect(service.media_ids).to eq([])
      end
    end
  end

  describe '#query_media_sizes' do
    context 'when all_files_file_size_lts is present on the media Solr doc' do
      let(:media_solr_docs) do
        [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => 5_000_000 }]
      end

      it 'returns the indexed total size (binary + derivatives) for each media_id' do
        service.query_media_fileset_ids
        expect(service.query_media_sizes[media_id]).to eq(5_000_000)
      end
    end

    context 'when all_files_file_size_lts is nil (media not yet re-indexed after derivatives were created)' do
      let(:media_solr_docs) do
        [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => nil }]
      end

      it 'returns nil for that media_id so query_bytes_consumed triggers the fallback' do
        service.query_media_fileset_ids
        expect(service.query_media_sizes[media_id]).to be_nil
      end
    end

    context 'when the media doc is absent from Solr results' do
      let(:media_solr_docs) { [] }

      it 'returns nil for each media_id in initial_media_ids' do
        service.query_media_fileset_ids
        expect(service.query_media_sizes[media_id]).to be_nil
      end
    end
  end

  describe '#query_bytes_consumed' do
    context 'when all_files_file_size_lts is indexed for all media' do
      let(:media_solr_docs) do
        [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => 3_000_000 }]
      end

      it 'sums the indexed total sizes directly without hitting the DB' do
        service.query_charge_information
        expect(service.query_bytes_consumed).to eq(3_000_000)
      end
    end

    context 'when all_files_file_size_lts is nil (triggers FileSetSizeInfo fallback)' do
      let(:media_solr_docs) do
        [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => nil }]
      end

      before do
        # Use binary_file_size so compute_sum_file_size sets sum_file_size = 1_200_000
        FileSetSizeInfo.create!(
          file_set_id:      fileset_id,
          media_id:         media_id,
          binary_file_size: 1_200_000
        )
        allow(Morphosource::DerivativePath).to receive(:derivatives_for_reference).with(media_id).and_return([])
      end

      it 'falls back to FileSetSizeInfo sum_file_size' do
        service.query_charge_information
        expect(service.query_bytes_consumed).to eq(1_200_000)
      end
    end
  end

  describe '#query_media_filesize' do
    let(:media_solr_docs) { [] }

    before do
      service.query_media_fileset_ids
      service.instance_variable_set(:@media_sizes, { media_id => nil })
      # Use binary + derivatives so compute_sum_file_size sets sum_file_size = 2_250_000
      FileSetSizeInfo.create!(
        file_set_id:                  fileset_id,
        media_id:                     media_id,
        binary_file_size:             2_000_000,
        summed_derivatives_file_size: 250_000
      )
      allow(Morphosource::DerivativePath).to receive(:derivatives_for_reference).with(media_id).and_return([])
    end

    it 'returns FileSetSizeInfo sum_file_size (binary + FileSet derivatives) plus media-level derivatives' do
      expect(service.query_media_filesize(media_id)).to eq(2_250_000)
    end

    it 'caches the computed total in media_sizes for use in query_bytes_consumed' do
      service.query_media_filesize(media_id)
      expect(service.media_sizes[media_id]).to eq(2_250_000)
    end

    context 'when media also has media-level derivatives on disk' do
      before do
        allow(Morphosource::DerivativePath)
          .to receive(:derivatives_for_reference).with(media_id)
          .and_return(['/derivatives/media_thumb.jpg'])
        allow(File).to receive(:size?).with('/derivatives/media_thumb.jpg').and_return(50_000)
      end

      it 'adds media-level derivative sizes on top of FileSetSizeInfo sum' do
        expect(service.query_media_filesize(media_id)).to eq(2_300_000)
      end
    end

    context 'when no FileSetSizeInfo rows exist for the media' do
      before { FileSetSizeInfo.where(media_id: media_id).destroy_all }

      it 'returns only the media-level derivative size (0 when none on disk)' do
        expect(service.query_media_filesize(media_id)).to eq(0)
      end
    end
  end

  describe '#generate_charge' do
    # 1 GB exactly so units_consumed is a clean 1.0 at billing_unit gb
    let(:media_solr_docs) do
      [{ 'id' => media_id, 'file_set_ids_ssim' => [fileset_id], 'all_files_file_size_lts' => 1_073_741_824 }]
    end

    it 'stores the total-including-derivatives size in media_size_hash' do
      service.query_charge_information
      charge = service.generate_charges.first
      expect(charge.media_size_hash[media_id]).to eq(1_073_741_824)
    end

    it 'records units_consumed based on the full file size including derivatives' do
      service.query_charge_information
      expect(service.units_consumed).to eq(1.0.to_d)
    end
  end
end
