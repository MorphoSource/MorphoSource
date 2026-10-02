require 'rails_helper'

RSpec.describe Hyrax::FileMetadata do
  # Hyrax::FileMetadata inherits from Dry::Struct (via Valkyrie::Resource), not from
  # ActiveModel, so it has no built-in valid? method. The original valid? override
  # performed a file integrity check, which is confusing for any caller expecting
  # standard attribute validation. It has been renamed to file_content_valid?.
  describe '#file_content_valid?' do
    let(:file_metadata) { described_class.new(recorded_size: [1234]) }
    let(:mock_file)     { instance_double(Valkyrie::StorageAdapter::File) }

    before { allow(file_metadata).to receive(:file).and_return(mock_file) }

    it 'delegates to file.valid? with size and sha256 digest' do
      allow(file_metadata).to receive(:checksum).and_return(nil)
      expect(mock_file).to receive(:valid?).with(size: 1234, digests: { sha256: nil })
      file_metadata.file_content_valid?
    end

    it 'passes the sha256 checksum when present' do
      checksum = instance_double('checksum', sha256: 'abc123')
      allow(file_metadata).to receive(:checksum).and_return([checksum])
      expect(mock_file).to receive(:valid?).with(size: 1234, digests: { sha256: 'abc123' })
      file_metadata.file_content_valid?
    end
  end

  describe '#valid?' do
    it 'is not defined on FileMetadata (no ActiveModel::Validations in ancestry)' do
      expect(described_class.new).not_to respond_to(:valid?)
    end
  end
end
