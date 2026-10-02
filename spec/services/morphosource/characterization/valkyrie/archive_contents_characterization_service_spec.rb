require 'rails_helper'

RSpec.describe Morphosource::Characterization::Valkyrie::ArchiveContentsCharacterizationService do
  describe '#extract_representative_content_and_others (private)' do
    let(:service) { described_class.allocate }
    let(:tmp_dir)  { Dir.mktmpdir }
    let(:zip_file) { Tempfile.new(['archive', '.zip'], tmp_dir) }

    after { FileUtils.remove_entry(tmp_dir) }

    context 'when the representative file is found in the archive' do
      let(:extracted_path) { File.join(tmp_dir, 'mesh.ply') }

      before do
        FileUtils.touch(extracted_path)
        allow(service).to receive(:tmp_dir_path).and_return(tmp_dir)
        allow(service).to receive(:source_file_path).and_return(zip_file.path)
        allow(service).to receive(:file_name).and_return('mesh.ply')
        archive_svc = instance_double(Morphosource::Files::ArchiveService,
                                      extract_archive: [extracted_path])
        allow(Morphosource::Files::ArchiveService).to receive(:new).and_return(archive_svc)
      end

      it 'opens the file with File.open, not Kernel#open' do
        # Kernel#open would accept a path starting with | as a pipe command.
        # File.open raises ArgumentError for such paths instead.
        result = service.send(:extract_representative_content_and_others)
        expect(result).to be_a(File)
        result.close
      end

      it 'does not call Kernel#open' do
        expect(service).not_to receive(:open)
        result = service.send(:extract_representative_content_and_others)
        result.close
      end
    end

    context 'when the representative file is not found in the archive' do
      before do
        allow(service).to receive(:tmp_dir_path).and_return(tmp_dir)
        allow(service).to receive(:source_file_path).and_return(zip_file.path)
        allow(service).to receive(:file_name).and_return('missing.ply')
        archive_svc = instance_double(Morphosource::Files::ArchiveService,
                                      extract_archive: ['/tmp/other_file.obj'])
        allow(Morphosource::Files::ArchiveService).to receive(:new).and_return(archive_svc)
      end

      it 'raises with a descriptive message' do
        expect { service.send(:extract_representative_content_and_others) }
          .to raise_error(RuntimeError, /missing\.ply/)
      end
    end
  end
end
