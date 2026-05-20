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
  end
end