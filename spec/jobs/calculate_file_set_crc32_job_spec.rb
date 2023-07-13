require 'rails_helper'
RSpec.describe CalculateFileSetCrc32Job do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    context 'file is remote' do
      # image from duke digital collections: https://repository.duke.edu/dc/hmp/hmpgp21657
      let(:file_path)  { "https://repository.duke.edu/iiif/ark:%2F87924%2Fr3ft8h245/full/200,/0/default.jpg" }
      let(:file_set)   { FileSet.create(import_url: file_path) }

      before do
        Hydra::Works::AddExternalFileToFileSet.call(file_set, file_set.import_url, :original_file, update_existing: true, versioning: false)
      end

      it 'returns the correct crc32' do
        described_class.perform_now(file_set.id)
        expect(file_set.reload.crc32).to eq([2489432479])
      end
    end

    context 'file is in fedora' do
      let(:file_set)    { FileSet.create }
      let(:file_path)   { fixture_path + '/bunny/bunny.glb' }
      let(:file)        { File.open(file_path) }

      before do
        Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file, versioning: true)
      end

      it 'returns the correct crc32' do
        described_class.perform_now(file_set.id)
        expect(file_set.reload.crc32).to eq([309217782])
      end
    end
  end
end
