# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::WorkingDirectory do
  describe '.write_to_temp_file' do
    let(:temp_file) { Tempfile.new('working-directory') }
    let(:file) { instance_double(Hydra::PCDM::File, original_name: url) }
    let(:url) { 'https://example.test/file.tif' }

    after do
      temp_file.close!
    end

    it 'streams remote URL when file set is remote-backed' do
      file_set = instance_double(FileSet, is_remote_backed?: true)
      expect(described_class).to receive(:stream_remote_url).with(url, temp_file)
      described_class.send(:write_to_temp_file, file, temp_file, file_set)
    end

    it 'streams Fedora file when file set is not remote-backed' do
      file_set = instance_double(FileSet, is_remote_backed?: false)
      expect(described_class).to receive(:stream_fedora_file).with(file, temp_file)
      described_class.send(:write_to_temp_file, file, temp_file, file_set)
    end
  end

  describe '.stream_fedora_file' do
    it 'writes streamed chunks to the temp file' do
      file = instance_double(Hydra::PCDM::File)
      allow(file).to receive(:stream).and_return(["abc", "def"].each)
      temp_file = Tempfile.new('working-directory')

      described_class.send(:stream_fedora_file, file, temp_file)
      temp_file.rewind

      expect(temp_file.read).to eq('abcdef')
    ensure
      temp_file.close!
    end
  end

  describe '.stream_remote_url' do
    it 'writes remote response body to the temp file' do
      response = Net::HTTPSuccess.new('1.1', '200', 'OK')
      allow(response).to receive(:read_body).and_yield('chunk')
      http = instance_double(Net::HTTP)
      allow(http).to receive(:request).and_yield(response)
      allow(Net::HTTP).to receive(:start).and_yield(http)

      temp_file = Tempfile.new('working-directory')
      described_class.send(:stream_remote_url, 'https://example.test/file.tif', temp_file)
      temp_file.rewind

      expect(temp_file.read).to eq('chunk')
    ensure
      temp_file.close!
    end
  end
end
