# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Valkyrie::Storage::ExternalUrl do
  let(:adapter) { described_class.new }
  let(:working_external_path) { Rails.root / 'tmp' / 'test_external_files' }

  before do
    allow(Hyrax.config).to receive(:working_external_path).and_return(working_external_path.to_s)
    FileUtils.mkdir_p(working_external_path)
  end

  after do
    FileUtils.rm_rf(working_external_path)
  end

  describe '#handles?' do
    it 'handles https:// URLs' do
      expect(adapter.handles?(id: Valkyrie::ID.new('https://example.com/file.obj'))).to be true
    end

    it 'handles http:// URLs' do
      expect(adapter.handles?(id: Valkyrie::ID.new('http://example.com/file.obj'))).to be true
    end

    it 'does not handle versiondisk:// IDs' do
      expect(adapter.handles?(id: Valkyrie::ID.new('versiondisk://path/to/file'))).to be false
    end

    it 'does not handle other protocols' do
      expect(adapter.handles?(id: Valkyrie::ID.new('s3://bucket/file'))).to be false
    end
  end

  describe '#supports?' do
    it 'returns false for all features' do
      expect(adapter.supports?(:versions)).to be false
      expect(adapter.supports?(:version_deletion)).to be false
    end
  end

  describe '#find_by' do
    context 'with a successful response' do
      before do
        stub_request(:get, 'https://example.com/test-file.txt')
          .to_return(status: 200, body: 'file contents', headers: { 'Content-Type' => 'text/plain' })
      end

      it 'returns a File with the URL as ID' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))

        expect(result).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(result.id.to_s).to eq('https://example.com/test-file.txt')
      end

      it 'defers the HTTP request until content is read' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))

        # No HTTP request made yet
        expect(a_request(:get, 'https://example.com/test-file.txt')).not_to have_been_made

        # Now read triggers the request
        expect(result.read).to eq('file contents')
        expect(a_request(:get, 'https://example.com/test-file.txt')).to have_been_made.once
      end

      it 'caches the file to disk under working_external_path' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))
        result.read

        digest = Digest::SHA256.hexdigest('https://example.com/test-file.txt')
        expected_path = File.join(working_external_path, digest, 'test-file.txt')
        expect(File.exist?(expected_path)).to be true
        expect(File.read(expected_path)).to eq('file contents')
      end

      it 'reuses cached file on subsequent access without re-downloading' do
        # First access downloads
        result1 = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))
        result1.read
        result1.close

        # Second access reuses cache
        result2 = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))
        expect(result2.read).to eq('file contents')

        # Only one HTTP request was made
        expect(a_request(:get, 'https://example.com/test-file.txt')).to have_been_made.once
      end

      it 'provides a disk_path pointing to the cached file' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://example.com/test-file.txt'))

        digest = Digest::SHA256.hexdigest('https://example.com/test-file.txt')
        expected_path = File.join(working_external_path, digest, 'test-file.txt')
        expect(result.disk_path.to_s).to eq(expected_path)
      end
    end

    context 'with a 404 response' do
      before do
        stub_request(:get, 'https://example.com/missing.txt')
          .to_return(status: 404, body: 'Not Found')
      end

      it 'raises FileNotFound when content is accessed' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://example.com/missing.txt'))

        expect {
          result.read
        }.to raise_error(Valkyrie::StorageAdapter::FileNotFound, /HTTP 404/)
      end
    end

    context 'with a connection error' do
      before do
        stub_request(:get, 'https://unreachable.example.com/file.txt')
          .to_raise(HTTP::ConnectionError.new('Connection refused'))
      end

      it 'raises FileNotFound when content is accessed' do
        result = adapter.find_by(id: Valkyrie::ID.new('https://unreachable.example.com/file.txt'))

        expect {
          result.read
        }.to raise_error(Valkyrie::StorageAdapter::FileNotFound, /Connection refused/)
      end
    end
  end

  describe '#upload' do
    it 'returns a File with the URL as ID without making HTTP requests' do
      result = adapter.upload(
        file: StringIO.new(''),
        original_filename: 'https://example.com/my-file.obj',
        resource: nil
      )

      expect(result).to be_a(Valkyrie::StorageAdapter::ExternalFile)
      expect(result.id.to_s).to eq('https://example.com/my-file.obj')

      # No HTTP request made (lazy IO defers download)
      expect(a_request(:get, 'https://example.com/my-file.obj')).not_to have_been_made
    end
  end

  describe '#delete' do
    it 'is a no-op and does not raise' do
      expect { adapter.delete(id: Valkyrie::ID.new('https://example.com/file.txt')) }.not_to raise_error
    end
  end

  describe '#find_versions' do
    it 'returns an empty array' do
      expect(adapter.find_versions(id: Valkyrie::ID.new('https://example.com/file.txt'))).to eq([])
    end
  end
end
