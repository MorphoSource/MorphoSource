# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ValkyrieCreateDerivativesJob do
  before do
    ActiveJob::Base.queue_adapter = :test

    # Stub the Lightbox HTTP call so tests pass without a running lightbox service.
    # process_file is the RestClient boundary; we write a minimal file to out_path
    # so that post_process (which checks existence and size) still runs for real.
    allow_any_instance_of(Morphosource::Derivatives::Lightbox).to receive(:process_file) do |lightbox|
      File.binwrite(lightbox.out_path, "stub-thumbnail")
      200
    end
  end

  # Helper: get the original FileMetadata for a file_set
  def get_file_metadata(file_set)
    Hyrax.custom_queries.find_original_file(file_set: file_set)
  end

  # Helper: set mime_type on file_metadata and persist it.
  # The :with_fixture_file factory does not run characterization, so mime_type
  # is blank. Setting it manually lets us test each mime_type branch of
  # MsFileSetDerivativesService without running a full characterization pass.
  def set_mime_type(file_metadata, mime_type)
    file_metadata.mime_type = mime_type
    Hyrax.persister.save(resource: file_metadata)
  end

  describe '#perform' do
    # -----------------------------------------------------------------------
    # Image derivative creation
    # -----------------------------------------------------------------------
    describe 'image derivative creation' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'images/ms.jpg')
      end
      let(:file_metadata) { get_file_metadata(file_set) }
      let(:thumbnail_path) do
        Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
      end

      before do
        set_mime_type(file_metadata, 'image/jpeg')
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end

      it 'creates a thumbnail derivative with non-zero file size' do
        expect(File.exist?(thumbnail_path)).to be true
        expect(File.size(thumbnail_path)).to be > 0
      end
    end

    # -----------------------------------------------------------------------
    # Mesh (PLY) derivative creation
    # -----------------------------------------------------------------------
    describe 'mesh (PLY) derivative creation' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'bunny/bunny.ply')
      end
      let(:file_metadata) { get_file_metadata(file_set) }
      let(:glb_path) do
        Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb')
      end
      let(:thumbnail_path) do
        Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'thumbnail')
      end

      before do
        set_mime_type(file_metadata, 'application/ply')
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end

      it 'creates a GLB derivative with non-zero file size' do
        expect(File.exist?(glb_path)).to be true
        expect(File.size(glb_path)).to be > 10000
      end

      it 'creates a thumbnail from the GLB derivative' do
        expect(File.exist?(thumbnail_path)).to be true
        expect(File.size(thumbnail_path)).to be > 0
      end
    end

    # -----------------------------------------------------------------------
    # Mesh (GLB) derivative creation
    # -----------------------------------------------------------------------
    describe 'mesh (GLB) derivative creation' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'bunny/bunny.glb')
      end
      let(:file_metadata) { get_file_metadata(file_set) }
      let(:glb_path) do
        Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb')
      end

      before do
        # GLB files are identified as model/gltf+json by the gltf-inspect characterizer
        set_mime_type(file_metadata, 'model/gltf+json')
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end

      it 'creates a GLB derivative with non-zero file size' do
        expect(File.exist?(glb_path)).to be true
        expect(File.size(glb_path)).to be > 10000
      end
    end

    # -----------------------------------------------------------------------
    # Archive (ZIP with Mesh parent) derivative creation
    # Stubs member_of on all Hyrax::FileSet instances so the job's re-fetched
    # file_set returns a parent work with media_type 'Mesh', causing the archive
    # branch to delegate to create_mesh_derivatives.
    # -----------------------------------------------------------------------
    describe 'archive (ZIP mesh) derivative creation' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'whale/whale-mpc-677-150k-4096-gltf.zip')
      end
      let(:file_metadata) { get_file_metadata(file_set) }
      let(:glb_path) do
        Morphosource::DerivativePath.derivative_path_for_reference(file_set, 'glb')
      end
      let(:parent_work) { double('parent_work', media_type: ['Mesh'], unit: ['mm'], is_remote_backed?: false, has_remote_manifest?: false, remote_manifest_url: nil) }

      before do
        set_mime_type(file_metadata, 'application/zip')
        allow_any_instance_of(Hyrax::FileSet).to receive(:member_of).and_return([parent_work])
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end

      it 'creates a GLB derivative from the archive with non-zero file size' do
        expect(File.exist?(glb_path)).to be true
        expect(File.size(glb_path)).to be > 10000
      end
    end

    # -----------------------------------------------------------------------
    # Remote-manifest guard: FileSets with a remote manifest must not trigger
    # a file download via disk_path. The guard returns before any derivative
    # creation so the storage adapter is never asked to fetch the file.
    # -----------------------------------------------------------------------
    describe 'remote-manifest guard' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'bunny/bunny.ply')
      end
      let(:file_metadata) { get_file_metadata(file_set) }

      before do
        set_mime_type(file_metadata, 'application/ply')
        allow_any_instance_of(Hyrax::FileSet).to receive(:has_remote_manifest?).and_return(true)
      end

      it 'skips derivative creation without accessing the storage adapter' do
        expect(Hyrax.storage_adapter).not_to receive(:find_by)
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end
    end

    # -----------------------------------------------------------------------
    # Video: returns early when FFmpeg is disabled
    # -----------------------------------------------------------------------
    describe 'video with ffmpeg disabled' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'images/ms.jpg')
      end
      let(:file_metadata) { get_file_metadata(file_set) }

      before do
        set_mime_type(file_metadata, 'video/mp4')
        allow(Hyrax.config).to receive(:enable_ffmpeg).and_return(false)
      end

      it 'skips derivative creation entirely' do
        expect(Morphosource::MsFileSetDerivativesService).not_to receive(:new)
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
      end
    end

    # -----------------------------------------------------------------------
    # Parent reindex: when the file_set is the parent work's thumbnail,
    # the parent should be reindexed after derivatives are created.
    # -----------------------------------------------------------------------
    describe 'parent reindex when file_set is the parent thumbnail' do
      let(:file_set) do
        FactoryBot.valkyrie_create(:valkyrie_file_set, :with_fixture_file,
                                   fixture_path: 'images/ms.jpg')
      end
      let(:file_metadata) { get_file_metadata(file_set) }
      let(:parent_work) { double('parent_work', thumbnail_id: file_set.id, is_remote_backed?: false, has_remote_manifest?: false) }

      before do
        set_mime_type(file_metadata, 'image/jpeg')
        allow_any_instance_of(Hyrax::FileSet).to receive(:member_of).and_return([parent_work])
        # Stub index_adapter.save completely — the parent is a test double,
        # not a real Valkyrie resource, so we can't let the indexer serialize it.
        allow(Hyrax.index_adapter).to receive(:save)
      end

      it 'reindexes the parent work' do
        described_class.perform_now(file_set.id.to_s, file_metadata.id.to_s)
        expect(Hyrax.index_adapter).to have_received(:save).with(resource: parent_work)
      end
    end
  end
end
