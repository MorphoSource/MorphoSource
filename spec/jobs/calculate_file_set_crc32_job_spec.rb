require 'rails_helper'
RSpec.describe CalculateFileSetCrc32Job do

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'perform' do
    context 'file is remote' do
      # thumbnail for https://www.morphosource.org/concern/media/000530653?locale=en
      let(:file_path) { "https://www.morphosource.org/downloads/000530688853?file=thumbnail&t=1686760977"}
      let(:file_set)  { FileSet.create(import_url: file_path) }

      before do
        Hydra::Works::AddExternalFileToFileSet.call(file_set, file_set.import_url, :original_file, update_existing: true, versioning: false)
      end

      # Don't fail if the file is not available
      it 'returns the correct crc32' do
        described_class.perform_now(file_set.id)
        expect(file_set.reload.crc32).to eq([1579858954])
      rescue OpenURI::HTTPError => e
        pending("Error accessing remote file: #{file_path}")
        raise e
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
