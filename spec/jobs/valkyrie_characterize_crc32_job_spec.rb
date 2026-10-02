require 'rails_helper'

RSpec.describe ValkyrieCharacterizeCrc32Job do
  def get_file_metadata(file_set)
    Hyrax.custom_queries.find_original_file(file_set: file_set)
  end

  describe '#perform' do
    # -----------------------------------------------------------------------
    # Local file
    # -----------------------------------------------------------------------
    context 'local file' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'images/ms.jpg')
      end
      let(:file_metadata) { get_file_metadata(file_set) }

      before { described_class.perform_now(file_metadata.id.to_s) }

      subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

      it 'saves a non-zero CRC32 checksum to the file metadata' do
        expect(subject.crc32).to be_present
        expect(Array(subject.crc32).first.to_i).to be > 0
      end

      it 'produces a consistent CRC32 for the same file content' do
        first_crc32 = Array(subject.crc32).first.to_i

        second_file_set = FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                                     fixture_path: 'images/ms.jpg')
        second_metadata = get_file_metadata(second_file_set)
        described_class.perform_now(second_metadata.id.to_s)
        second_result = Hyrax.custom_queries.find_file_metadata_by(id: second_metadata.id)

        expect(Array(second_result.crc32).first.to_i).to eq(first_crc32)
      end
    end

    # -----------------------------------------------------------------------
    # External URL file
    # -----------------------------------------------------------------------
    context 'external URL file' do
      let(:working_external_path) { Rails.root.join('tmp', 'test_crc32_external_cache') }
      let(:remote_url) { 'https://remote.example.com/files/crc32-test.jpg' }
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_external_file, remote_url: remote_url)
      end
      let(:file_metadata) { get_file_metadata(file_set) }

      before do
        FileUtils.mkdir_p(working_external_path)
        allow(Hyrax.config).to receive(:working_external_path).and_return(working_external_path.to_s)
        stub_request(:get, remote_url)
          .to_return(body: File.binread(Rails.root.join('spec', 'fixtures', 'images', 'ms.jpg')), status: 200)
        described_class.perform_now(file_metadata.id.to_s)
      end

      after { FileUtils.rm_rf(working_external_path) }

      subject { Hyrax.custom_queries.find_file_metadata_by(id: file_metadata.id) }

      it 'saves a non-zero CRC32 checksum to the file metadata' do
        expect(subject.crc32).to be_present
        expect(Array(subject.crc32).first.to_i).to be > 0
      end

      it 'produces the same CRC32 as a local copy of the same content' do
        remote_crc32 = Array(subject.crc32).first.to_i

        local_file_set = FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                                    fixture_path: 'images/ms.jpg')
        local_metadata = get_file_metadata(local_file_set)
        described_class.perform_now(local_metadata.id.to_s)
        local_result = Hyrax.custom_queries.find_file_metadata_by(id: local_metadata.id)

        expect(Array(local_result.crc32).first.to_i).to eq(remote_crc32)
      end
    end

    # -----------------------------------------------------------------------
    # Event publishing
    # -----------------------------------------------------------------------
    context 'event publishing' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'images/ms.jpg')
      end
      let(:file_metadata) { get_file_metadata(file_set) }

      it 'publishes file.metadata.updated with the saved metadata and system user' do
        expect(Hyrax.publisher).to receive(:publish).with(
          'file.metadata.updated',
          hash_including(
            metadata: kind_of(Hyrax::FileMetadata),
            user: ::User.system_user
          )
        )
        described_class.perform_now(file_metadata.id.to_s)
      end
    end
  end
end
