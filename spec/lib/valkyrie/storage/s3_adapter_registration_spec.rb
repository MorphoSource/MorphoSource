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
    # The globally registered :s3 adapter builds its Aws::S3::Client at Rails boot time,
    # before Aws.config[:stub_responses] could be toggled here -- stub_responses is only
    # honored at client construction, so we build an isolated adapter with its own
    # stubbed client instead of reusing the shared boot-time adapter.
    # AWS's stubbed responses don't produce a real checksum, so pass a no-op verifier --
    # exercising the real checksum verifier requires an actual S3-compatible endpoint,
    # already covered by manual verification against local MinIO.
    let(:no_op_verifier) { double('verifier', verify_checksum: true) } # rubocop:disable RSpec/VerifiedDoubles
    let(:adapter) do
      Valkyrie::Storage::VersionedShrine.new(
        Valkyrie::Shrine::Storage::S3.new(bucket: 'test-bucket', region: 'us-east-1', stub_responses: true),
        no_op_verifier
      )
    end
    let(:resource) { instance_double(Hyrax::FileSet, id: Valkyrie::ID.new(SecureRandom.uuid)) }

    # Only upload is exercised here -- VersionedShrine#delete depends on head_object/
    # list_objects_v2 reflecting real bucket state, which AWS's generic stub responses
    # don't track across calls. Delete is verified for real against local MinIO instead
    # (see PR verification steps), where it round-trips correctly.
    it 'uploads a file' do
      file = Tempfile.new(['test', '.txt'])
      file.write('s3 test content')
      file.rewind

      uploaded = adapter.upload(file: file, original_filename: 'test.txt', resource: resource)
      expect(uploaded.id.to_s).to start_with(adapter.protocol)

      file.close
      file.unlink
    end
  end
end
