require 'rails_helper'

RSpec.describe Hyrax::MediaMemberPresenterFactory do
  let(:ability) { instance_double(Ability) }

  describe 'media member presenter factory' do
    it 'has MediaFileSetPresenter as the file_presenter_class' do
      expect(described_class.file_presenter_class).to eq(Hyrax::MediaFileSetPresenter)
    end
  end

  describe '#ordered_ids' do
    it 'reads member IDs from member_ids_ssim' do
      work = SolrDocument.new('member_ids_ssim' => ['id-1', 'id-2'])
      factory = described_class.new(work, ability)
      expect(factory.ordered_ids).to eq(['id-1', 'id-2'])
    end

    it 'returns an empty array when member_ids_ssim is absent' do
      work = SolrDocument.new({})
      factory = described_class.new(work, ability)
      expect(factory.ordered_ids).to eq([])
    end

    it 'includes IDs from valkyrie_member_ids_ssim' do
      work = SolrDocument.new('valkyrie_member_ids_ssim' => ['v-uuid-1'])
      factory = described_class.new(work, ability)
      expect(factory.ordered_ids).to include('v-uuid-1')
    end

    it 'unions member_ids_ssim and valkyrie_member_ids_ssim without duplicates' do
      work = SolrDocument.new(
        'member_ids_ssim'          => ['id-1', 'shared'],
        'valkyrie_member_ids_ssim' => ['shared', 'v-uuid-1']
      )
      factory = described_class.new(work, ability)
      expect(factory.ordered_ids).to match_array(['id-1', 'shared', 'v-uuid-1'])
    end
  end

  describe '#file_set_ids (private)' do
    it 'reads file set IDs from file_set_ids_ssim' do
      work = SolrDocument.new('file_set_ids_ssim' => ['fs-1', 'fs-2'])
      factory = described_class.new(work, ability)
      expect(factory.send(:file_set_ids)).to eq(['fs-1', 'fs-2'])
    end

    it 'returns an empty array when file_set_ids_ssim is absent' do
      work = SolrDocument.new({})
      factory = described_class.new(work, ability)
      expect(factory.send(:file_set_ids)).to eq([])
    end

    it 'includes IDs from valkyrie_member_ids_ssim' do
      work = SolrDocument.new('valkyrie_member_ids_ssim' => ['v-uuid-1'])
      factory = described_class.new(work, ability)
      expect(factory.send(:file_set_ids)).to include('v-uuid-1')
    end

    it 'unions file_set_ids_ssim and valkyrie_member_ids_ssim without duplicates' do
      work = SolrDocument.new(
        'file_set_ids_ssim'        => ['fs-1', 'shared'],
        'valkyrie_member_ids_ssim' => ['shared', 'v-uuid-1']
      )
      factory = described_class.new(work, ability)
      expect(factory.send(:file_set_ids)).to match_array(['fs-1', 'shared', 'v-uuid-1'])
    end
  end

  # Integration: verify that a Valkyrie-only FileSet (in valkyrie_member_ids_ssim but
  # absent from member_ids_ssim / file_set_ids_ssim) appears in the presenter list,
  # which was the root cause of "No file uploaded" for newly ingested Valkyrie FileSets.
  describe 'Valkyrie-only FileSets produce file presenters' do
    let(:valkyrie_uuid) { 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee' }
    let(:work) do
      SolrDocument.new(
        'valkyrie_member_ids_ssim' => [valkyrie_uuid],
        'member_ids_ssim'          => [],
        'file_set_ids_ssim'        => []
      )
    end
    let(:factory) { described_class.new(work, ability) }

    it 'includes the Valkyrie UUID in ordered_ids' do
      expect(factory.ordered_ids).to include(valkyrie_uuid)
    end

    it 'includes the Valkyrie UUID in file_set_ids' do
      expect(factory.send(:file_set_ids)).to include(valkyrie_uuid)
    end
  end
end
