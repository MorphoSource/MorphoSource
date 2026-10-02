# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Valkyrie::Storage::Hoard do
  let(:test_path) { Rails.root / 'tmp' / 'hoard_test_uploads' }
  let(:versioned_disk) { Valkyrie::Storage::VersionedDisk.new(base_path: test_path) }
  let(:external_url) { Valkyrie::Storage::ExternalUrl.new }
  let(:hoard) { described_class.new(services: [versioned_disk, external_url]) }
  let(:working_external_path) { Rails.root / 'tmp' / 'hoard_test_external' }
  let(:resource) { instance_double(Hyrax::FileSet, id: Valkyrie::ID.new(SecureRandom.uuid)) }

  before do
    FileUtils.mkdir_p(test_path)
    allow(Hyrax.config).to receive(:working_external_path).and_return(working_external_path.to_s)
    FileUtils.mkdir_p(working_external_path)

    # Webmock will block ActiveFedora::Cleaner.clean! but we don't need it anyway
    stub_request(:head, "http://fcrepo:8080/fcrepo/rest/test").
      with(
        headers: {
      'Accept'=>'*/*',
      'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
      'Authorization'=>'Basic ZmVkb3JhQWRtaW46ZmVkb3JhQWRtaW4=',
      'User-Agent'=>'Faraday v2.13.1'
        }).
      to_return(status: 200, body: "", headers: {})
  end

  after do
    FileUtils.rm_rf(test_path)
    FileUtils.rm_rf(working_external_path)
  end

  describe '#handles?' do
    it 'returns true for versiondisk:// IDs' do
      id = Valkyrie::ID.new("versiondisk://#{test_path}/some/file.txt")
      expect(hoard.handles?(id: id)).to be true
    end

    it 'returns true for https:// IDs' do
      id = Valkyrie::ID.new('https://example.com/file.txt')
      expect(hoard.handles?(id: id)).to be true
    end

    it 'returns true for http:// IDs' do
      id = Valkyrie::ID.new('http://example.com/file.txt')
      expect(hoard.handles?(id: id)).to be true
    end

    it 'returns false for unrecognized IDs' do
      id = Valkyrie::ID.new('s3://bucket/file.txt')
      expect(hoard.handles?(id: id)).to be false
    end
  end

  describe '#supports?' do
    it 'delegates to the primary service' do
      expect(hoard.supports?(:versions)).to be true
      expect(hoard.supports?(:version_deletion)).to be true
    end

    it 'returns false for unsupported features' do
      expect(hoard.supports?(:unknown_feature)).to be false
    end
  end

  describe '#upload' do
    it 'routes local files to VersionedDisk' do
      file = Tempfile.new(['test', '.txt'])
      file.write('test content')
      file.rewind

      result = hoard.upload(file: file, original_filename: 'test.txt', resource: resource)

      expect(result).to be_a(Valkyrie::StorageAdapter::File)
      expect(result.id.to_s).to start_with('versiondisk://')

      file.close
      file.unlink
    end

    it 'routes HTTP URLs to ExternalFile' do
      result = hoard.upload(
        file: StringIO.new(''),
        original_filename: 'https://example.com/remote-file.obj',
        resource: resource
      )

      expect(result).to be_a(Valkyrie::StorageAdapter::ExternalFile)
      expect(result.id.to_s).to eq('https://example.com/remote-file.obj')
    end

    it 'falls back to primary service for unrecognized filenames' do
      file = Tempfile.new(['test', '.txt'])
      file.write('fallback content')
      file.rewind

      result = hoard.upload(file: file, original_filename: 'plain-file.txt', resource: resource)

      expect(result).to be_a(Valkyrie::StorageAdapter::File)
      expect(result.id.to_s).to start_with('versiondisk://')

      file.close
      file.unlink
    end
  end

  describe '#find_by' do
    it 'routes versiondisk IDs to VersionedDisk' do
      file = Tempfile.new(['test', '.txt'])
      file.write('test content')
      file.rewind

      uploaded = hoard.upload(file: file, original_filename: 'test.txt', resource: resource)
      found = hoard.find_by(id: uploaded.id)

      expect(found.id.to_s).to eq(uploaded.id.to_s)
      expect(found.read).to eq('test content')

      file.close
      file.unlink
    end

    it 'routes https IDs to ExternalFile' do
      stub_request(:get, 'https://example.com/remote.txt')
        .to_return(status: 200, body: 'remote content')

      result = hoard.find_by(id: Valkyrie::ID.new('https://example.com/remote.txt'))

      expect(result).to be_a(Valkyrie::StorageAdapter::ExternalFile)
      expect(result.id.to_s).to eq('https://example.com/remote.txt')
      expect(result.read).to eq('remote content')
    end

    it 'raises FileNotFound for IDs no service handles' do
      id = Valkyrie::ID.new('s3://bucket/file.txt')
      expect { hoard.find_by(id: id) }.to raise_error(Valkyrie::StorageAdapter::FileNotFound)
    end
  end

  describe '#delete' do
    it 'deletes local files via VersionedDisk' do
      file = Tempfile.new(['test', '.txt'])
      file.write('test content')
      file.rewind

      uploaded = hoard.upload(file: file, original_filename: 'test.txt', resource: resource)
      hoard.delete(id: uploaded.id)

      expect { hoard.find_by(id: uploaded.id) }.to raise_error(Valkyrie::StorageAdapter::FileNotFound)

      file.close
      file.unlink
    end

    it 'is a no-op for external URLs' do
      id = Valkyrie::ID.new('https://example.com/file.txt')
      expect { hoard.delete(id: id) }.not_to raise_error
    end
  end

  describe '#find_versions' do
    it 'returns versions for local files' do
      file = Tempfile.new(['test', '.txt'])
      file.write('v1 content')
      file.rewind

      uploaded = hoard.upload(file: file, original_filename: 'test.txt', resource: resource)
      versions = hoard.find_versions(id: uploaded.id)

      expect(versions).to be_an(Array)
      expect(versions.length).to be >= 1

      file.close
      file.unlink
    end

    it 'returns empty array for external URLs' do
      id = Valkyrie::ID.new('https://example.com/file.txt')
      expect(hoard.find_versions(id: id)).to eq([])
    end
  end
end
