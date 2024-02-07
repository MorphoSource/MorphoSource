require 'rails_helper'

RSpec.describe IIIFManifest::FileSetManager do

  describe 'PRESENTER_TYPES' do
    it { expect(described_class::PRESENTER_TYPES).to include(
      'Mesh' => 'mesh',
      'CTImageSeries' => 'volume',
      'Image' => 'image',
      'Video' => 'video'
    ) }
  end

  describe 'results' do
    let(:media)       { FactoryBot.create(:media, media_type: media_type, visibility: 'open', fileset_visibility: ['open']) }
    let(:file_set)    { FileSet.create }
    let(:file_path)   { fixture_path + '/text/text.txt' }
    let(:file)        { File.open(file_path) }
    let(:mime_type)   { 'rtf/text' }
    let(:solr_doc)    { SolrDocument.find(media.id) }

    subject           { described_class.new(Hyrax::IiifManifestPresenter.new(solr_doc)) }

    before do
      Hydra::Works::AddFileToFileSet.call(file_set, file, :original_file, versioning: true)
      media.ordered_members << file_set
      media.save!
      InheritPermissionsJob.perform_now(media)
      allow(file_set).to receive(:mime_type).and_return(mime_type)
      file_set.update_index
    end

    context 'when media is a mesh' do
      let(:media_type) { ['Mesh'] }

      context 'when file is a mesh' do
        let(:mime_type) { 'application/ply' }

        it 'returns DisplayImagePresenter' do
          expect(subject.results.first).to be_a(Hyrax::IiifManifestPresenter::DisplayImagePresenter)
        end
      end
      context 'when file is not a mesh' do
        it { expect(subject.results).to eq([]) }
      end
    end

    context 'when media is a CTImageSeries' do
      let(:media_type) { ['CTImageSeries'] }

      context 'when file is a CT Image Series' do
        let(:mime_type) { 'application/zip' }

        it 'returns DisplayImagePresenter' do
          expect(subject.results.first).to be_a(Hyrax::IiifManifestPresenter::DisplayImagePresenter)
        end
      end
      context 'when file is not a CTImageSeries' do
        it { expect(subject.results).to eq([]) }
      end
    end

    context 'when media is an image' do
      let(:media_type) { ['Image'] }

      context 'when file is a CT Image Series' do
        let(:mime_type) { 'image/png' }

        it 'returns DisplayImagePresenter' do
          expect(subject.results.first).to be_a(Hyrax::IiifManifestPresenter::DisplayImagePresenter)
        end
      end
      context 'when file is not an image' do
        it { expect(subject.results).to eq([]) }
      end
    end

    context 'when media is a video' do
      let(:media_type) { ['Video'] }

      context 'when file is a CT Image Series' do
        let(:mime_type) { 'video/mpeg' }

        it 'returns DisplayImagePresenter' do
          expect(subject.results.first).to be_a(Hyrax::IiifManifestPresenter::DisplayImagePresenter)
        end
      end
      context 'when file is not a video' do
        it { expect(subject.results).to eq([]) }
      end
    end
  end
end