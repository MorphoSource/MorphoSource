require 'rails_helper'

RSpec.describe PrepareCharacterizeJob do
  before { ActiveJob::Base.queue_adapter = :test }

  describe '#perform' do
    context 'with a Valkyrie FileSet' do
      let(:work_id) { 'valkyrie-fs-id' }
      let(:file_set) { instance_double(Hyrax::FileSet, has_remote_manifest?: false) }
      let(:file_metadata) { instance_double(Hyrax::FileMetadata, id: Valkyrie::ID.new('meta-id')) }

      before do
        allow(ActiveFedora::Base).to receive(:find).with(work_id)
          .and_raise(ActiveFedora::ObjectNotFoundError)
        allow(Hyrax.query_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new(work_id)).and_return(file_set)
        allow(file_set).to receive(:is_a?).with(::Valkyrie::Resource).and_return(true)
        allow(Hyrax.custom_queries).to receive(:find_original_file)
          .with(file_set: file_set).and_return(file_metadata)
      end

      it 'enqueues ValkyrieCharacterizationJob' do
        expect(ValkyrieCharacterizationJob).to receive(:perform_later).with('meta-id')
        described_class.perform_now(work_id)
      end

      context 'when file_set has a remote manifest' do
        before { allow(file_set).to receive(:has_remote_manifest?).and_return(true) }

        it 'does not enqueue ValkyrieCharacterizationJob' do
          expect(ValkyrieCharacterizationJob).not_to receive(:perform_later)
          described_class.perform_now(work_id)
        end
      end
    end

    context 'with an AF Media work' do
      let(:work_id) { 'media-id' }
      let(:original_file) { instance_double(Hydra::PCDM::File, id: 'orig-file-id') }
      let(:file_set) do
        instance_double(::FileSet, id: 'fs-id', is_remote_backed?: false, original_file: original_file)
      end
      let(:media) { instance_double(Media, file_sets: [file_set]) }
      let(:wrapper) { instance_double(JobIoWrapper, uploaded_file: nil, path: '/hint/path') }

      before do
        allow(ActiveFedora::Base).to receive(:find).with(work_id).and_return(media)
        allow(media).to receive(:class).and_return(Media)
        allow(JobIoWrapper).to receive(:find_by).with(file_set_id: 'fs-id').and_return(wrapper)
      end

      it 'enqueues CharacterizeJob with path hint' do
        expect(CharacterizeJob).to receive(:perform_later).with(file_set, 'orig-file-id', '/hint/path')
        described_class.perform_now(work_id)
      end
    end

    context 'with a FileSet id that has already been migrated to Postgres' do
      # Migration never deletes the legacy AF Fedora object (only unlinks it from the
      # parent's AF membership), so ActiveFedora::Base.find would otherwise succeed
      # against that stale record. resolve_file_set must prefer the real Postgres
      # resource and never even reach ActiveFedora::Base.find in this case.
      let(:work_id) { 'migrated-fs-id' }
      let(:file_set) { instance_double(Hyrax::FileSet, has_remote_manifest?: false) }
      let(:file_metadata) { instance_double(Hyrax::FileMetadata, id: Valkyrie::ID.new('meta-id')) }
      let(:postgres_service) { instance_double(Valkyrie::Persistence::Postgres::QueryService) }

      before do
        allow(Hyrax.query_service).to receive(:postgres_service).and_return(postgres_service)
        allow(postgres_service).to receive(:find_by)
          .with(id: Valkyrie::ID.new(work_id)).and_return(file_set)
        allow(file_set).to receive(:respond_to?).with(:file_set?).and_return(true)
        allow(file_set).to receive(:file_set?).and_return(true)
        allow(file_set).to receive(:is_a?).with(::Valkyrie::Resource).and_return(true)
        allow(Hyrax.custom_queries).to receive(:find_original_file)
          .with(file_set: file_set).and_return(file_metadata)
      end

      it 'resolves the Postgres-native FileSet without consulting ActiveFedora::Base.find' do
        expect(ActiveFedora::Base).not_to receive(:find)
        expect(ValkyrieCharacterizationJob).to receive(:perform_later).with('meta-id')
        described_class.perform_now(work_id)
      end
    end

    context 'with an AF FileSet passed directly' do
      let(:work_id) { 'fs-id' }
      let(:original_file) { instance_double(Hydra::PCDM::File, id: 'orig-file-id') }
      let(:file_set) do
        instance_double(::FileSet, id: 'fs-id', is_remote_backed?: false, original_file: original_file,
                        file_set?: true)
      end
      let(:wrapper) { instance_double(JobIoWrapper, uploaded_file: nil, path: '/hint/path') }

      before do
        allow(ActiveFedora::Base).to receive(:find).with(work_id).and_return(file_set)
        allow(file_set).to receive(:class).and_return(::FileSet)
        allow(file_set).to receive(:respond_to?).with(:file_set?).and_return(true)
        allow(JobIoWrapper).to receive(:find_by).with(file_set_id: 'fs-id').and_return(wrapper)
      end

      it 'enqueues CharacterizeJob' do
        expect(CharacterizeJob).to receive(:perform_later).with(file_set, 'orig-file-id', '/hint/path')
        described_class.perform_now(work_id)
      end
    end
  end
end
