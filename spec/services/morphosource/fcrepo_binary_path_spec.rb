require 'rails_helper'

RSpec.describe Morphosource::FcrepoBinaryPath do
  around do |example|
    original = Hyrax.config.fcrepo_binary_directory_path
    Hyrax.config.fcrepo_binary_directory_path = '/file-storage/fcrepo.binary.directory'
    example.run
    Hyrax.config.fcrepo_binary_directory_path = original
  end

  describe '.for' do
    it 'splits the first 6 hex chars of the digest into 3 subdirectories, then the full hash as filename' do
      digest = 'urn:sha1:9f8b04466128785acc6d3e29e5d209ff27c1fe09'
      expect(described_class.for(digest).to_s).to eq(
        '/file-storage/fcrepo.binary.directory/9f/8b/04/9f8b04466128785acc6d3e29e5d209ff27c1fe09'
      )
    end

    it 'accepts a bare hash with no urn:sha1: prefix' do
      digest = '9f8b04466128785acc6d3e29e5d209ff27c1fe09'
      expect(described_class.for(digest).to_s).to end_with(
        '9f/8b/04/9f8b04466128785acc6d3e29e5d209ff27c1fe09'
      )
    end

    it 'raises for something that is not a well-formed SHA-1 hex digest' do
      expect { described_class.for('not-a-digest') }.to raise_error(ArgumentError)
    end
  end
end
