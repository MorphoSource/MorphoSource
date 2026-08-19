# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Valkyrie :s3 storage adapter registration' do
  let(:adapter) { Valkyrie::StorageAdapter.find(:s3) }
  let(:s3_config) do
    YAML.safe_load(
      ERB.new(File.read(Rails.root.join('config', 's3.yml'))).result,
      permitted_classes: [Symbol],
      aliases: true
    )[Rails.env]
  end

  it 'registers :s3 as a Valkyrie::Storage::VersionedShrine' do
    expect(adapter).to be_a(Valkyrie::Storage::VersionedShrine)
  end

  it 'configures the underlying S3 storage with config/s3.yml values' do
    expect(adapter.shrine.bucket.name).to eq(s3_config['bucket'])
  end

  it 'does not change the default storage adapter or Hoard services' do
    expect(Valkyrie.config.storage_adapter).to be_a(Valkyrie::Storage::Hoard)

    hoard = Valkyrie::StorageAdapter.find(:hoard)
    expect(hoard.services.map(&:class)).to eq([Valkyrie::Storage::VersionedDisk, Valkyrie::Storage::ExternalUrl])
  end

  describe 'CRUD against stubbed S3' do
    let(:resource) { instance_double(Hyrax::FileSet, id: Valkyrie::ID.new(SecureRandom.uuid)) }

    around do |example|
      original = Aws.config[:stub_responses]
      Aws.config[:stub_responses] = true
      example.run
      Aws.config[:stub_responses] = original
    end

    it 'uploads and deletes a file' do
      file = Tempfile.new(['test', '.txt'])
      file.write('s3 test content')
      file.rewind

      uploaded = adapter.upload(file: file, original_filename: 'test.txt', resource: resource)
      expect(uploaded.id.to_s).to start_with(adapter.protocol)

      expect { adapter.delete(id: uploaded.id) }.not_to raise_error

      file.close
      file.unlink
    end
  end
end
