require 'rails_helper'
require 'browse_everything/retriever'

RSpec.describe ValkyrieRemoteIngestJob do
  let(:user)            { create(:user) }
  let(:fixture_path)    { Rails.root.join('spec/fixtures/images/duke.png').to_s }
  let(:fixture_content) { File.binread(fixture_path) }

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Reload a FileSet directly from Postgres (bypasses any find_by stubs).
  def reload_file_set(id)
    Hyrax.query_service.postgres_service.find_by(id: id.to_s)
  end

  def original_file_metadata(file_set)
    Hyrax.custom_queries.find_original_file(file_set: file_set)
  end

  def storage_file_for(file_set)
    fm = original_file_metadata(file_set)
    Valkyrie.config.storage_adapter.find_by(id: fm.file_identifier)
  end

  # ---------------------------------------------------------------------------
  # Shared stubs
  # ---------------------------------------------------------------------------
  before do
    # Stub the Hyrax::Operation DB insert used by remote-URL scenarios (2-4).
    @operation = instance_double(Hyrax::Operation, performing!: nil, success!: nil, 'fail!': nil)
    allow(Hyrax::Operation).to receive(:create!).and_return(@operation)

    # Suppress downstream jobs that require Fedora-backed works.
    allow(ValkyrieCharacterizationJob).to receive(:perform_later)
    allow(FileSetAttachedEventJob).to receive(:perform_later)
  end

  # ---------------------------------------------------------------------------
  # Scenario 1 — file:// URI (local file, e.g. BrowseEverything Globus)
  # ---------------------------------------------------------------------------
  context "scenario 1: file:// URI (local file)" do
    let(:file_set) do
      # No label — the job sets it from the filename.
      Hyrax.persister.save(resource: Hyrax::FileSet.new(depositor: user.user_key))
    end
    let(:file_info) { { url: "file://#{fixture_path}", file_name: 'duke.png' } }

    before do
      allow(Hyrax.config).to receive(:whitelisted_ingest_dirs)
        .and_return([Rails.root.join('spec/fixtures').to_s])
    end

    it "stores the file on disk, content matches fixture, and sets label/title" do
      described_class.perform_now(file_set, file_info)

      fs = reload_file_set(file_set.id)
      sf = storage_file_for(fs)
      expect(sf).to be_a(Valkyrie::StorageAdapter::File)
      expect(File.binread(sf.disk_path)).to eq(fixture_content)
      expect(fs.label).to eq('duke.png')
      expect(fs.title).to include('duke.png')
    end

    context "when the file:// path is not in a whitelisted dir" do
      let(:file_info) { { url: 'file:///forbidden/path/file.ply', file_name: 'file.ply' } }

      it "logs an error and does not call ValkyrieUpload" do
        expect(Morphosource::ValkyrieUpload).not_to receive(:file)
        described_class.perform_now(file_set, file_info)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 2 — BrowseEverything URL (download via retriever, non-remote-backed)
  # ---------------------------------------------------------------------------
  context "scenario 2: BrowseEverything URL (non-remote-backed)" do
    let(:remote_url) { 'https://browse.example.com/files/model.ply' }
    let(:file_info)  { { url: remote_url, file_name: 'model.ply', auth_header: { 'Authorization' => 'Bearer tok' } } }

    let(:file_set) do
      # import_url is set by WorkUploadsHandler before the job runs.
      Hyrax.persister.save(resource: Hyrax::FileSet.new(
        depositor: user.user_key,
        label: 'model.ply',
        title: ['model.ply'],
        import_url: remote_url
      ))
    end

    before do
      retriever = instance_double(BrowseEverything::Retriever)
      allow(BrowseEverything::Retriever).to receive(:new).and_return(retriever)
      allow(BrowseEverything::Retriever).to receive(:can_retrieve?).and_return(true)
      # Yield the real fixture content so the tempfile contains actual bytes.
      allow(retriever).to receive(:retrieve).and_yield(fixture_content)
    end

    it "stores the file on disk, sets label/title/import_url, and marks operation successful" do
      described_class.perform_now(file_set, file_info)

      fs = reload_file_set(file_set.id)
      sf = storage_file_for(fs)
      expect(sf).to be_a(Valkyrie::StorageAdapter::File)
      expect(File.binread(sf.disk_path)).to eq(fixture_content)
      expect(fs.label).to eq('model.ply')
      expect(fs.title).to include('model.ply')
      expect(fs.import_url).to eq(remote_url)
      expect(@operation).to have_received(:success!)
    end

    context "when BrowseEverything reports the URL has expired" do
      before do
        allow(BrowseEverything::Retriever).to receive(:can_retrieve?).and_return(false)
        allow(Hyrax.config.callback).to receive(:run)
          .with(:after_import_url_failure, anything, anything)
      end

      it "fails the operation and does not call ValkyrieUpload" do
        expect(Morphosource::ValkyrieUpload).not_to receive(:file)
        expect(@operation).to receive(:fail!)
        described_class.perform_now(file_set, file_info)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 3 — remote-backed URL, no manifest (download to cache then register)
  # ---------------------------------------------------------------------------
  context "scenario 3: remote-backed URL without remote manifest" do
    let(:working_external_path) { Rails.root.join('tmp', 'test_remote_ingest_cache') }

    before do
      FileUtils.mkdir_p(working_external_path)
      allow(Hyrax.config).to receive(:working_external_path)
        .and_return(working_external_path.to_s)
    end

    after { FileUtils.rm_rf(working_external_path) }

    context "with a URL whose path has a recognisable filename" do
      let(:remote_url) { 'https://remote.example.com/specimens/model.ply' }
      let(:file_info)  { { url: remote_url, file_name: 'model.ply' } }

      let(:file_set) do
        # import_url is set by WorkUploadsHandler before the job runs.
        Hyrax.persister.save(resource: Hyrax::FileSet.new(
          depositor: user.user_key,
          label: 'model.ply',
          title: ['model.ply'],
          import_url: remote_url
        ))
      end

      before do
        allow(file_set).to receive(:is_remote_backed?).and_return(true)
        allow(file_set).to receive(:has_remote_manifest?).and_return(false)
        allow(file_set).to receive(:parent).and_return(double(organization_id: []))
        allow(user).to receive(:can_submit_remote_file?).and_return(true)

        # Stub both GET (for download_to_external_cache via URI.open) and
        # HEAD (for MorphosourceHelper::RemoteFileInfo e_tag look-up).
        stub_request(:get,  remote_url).to_return(body: fixture_content, status: 200)
        stub_request(:head, remote_url).to_return(status: 200,
                                                   headers: { 'Content-Type' => 'application/ply' })
      end

      it "registers an ExternalFile, sets label/title/import_url, downloads cache, and marks operation successful" do
        described_class.perform_now(file_set, file_info)

        fs = reload_file_set(file_set.id)
        sf = storage_file_for(fs)
        digest     = Digest::SHA256.hexdigest(remote_url)
        cache_path = File.join(working_external_path.to_s, digest, 'model.ply')
        expect(sf).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(sf.id.to_s).to eq(remote_url)
        expect(fs.label).to eq('model.ply')
        expect(fs.title).to include('model.ply')
        expect(fs.import_url).to eq(remote_url)
        expect(File.exist?(cache_path)).to be true
        expect(@operation).to have_received(:success!)
      end

      context "when the user is not allowed to submit the remote file" do
        before do
          allow(user).to receive(:can_submit_remote_file?).and_return(false)
          allow(Hyrax.config.callback).to receive(:run)
            .with(:after_import_url_failure, anything, anything)
        end

        it "fails the operation and does not call ValkyrieUpload" do
          expect(Morphosource::ValkyrieUpload).not_to receive(:file)
          expect(@operation).to receive(:fail!)
          described_class.perform_now(file_set, file_info)
        end
      end
    end

    # -------------------------------------------------------------------------
    # Scenario 3 variant — opaque URL (no filename extension in path)
    # -------------------------------------------------------------------------
    context "with an opaque URL that has no filename extension" do
      let(:remote_url) { 'https://remote.example.com/opaquefile' }
      let(:file_info)  { { url: remote_url, file_name: 'opaquefile' } }

      let(:file_set) do
        # import_url is set by WorkUploadsHandler before the job runs.
        Hyrax.persister.save(resource: Hyrax::FileSet.new(
          depositor: user.user_key,
          label: 'opaquefile',
          title: ['opaquefile'],
          import_url: remote_url
        ))
      end

      before do
        allow(file_set).to receive(:is_remote_backed?).and_return(true)
        allow(file_set).to receive(:has_remote_manifest?).and_return(false)
        allow(file_set).to receive(:parent).and_return(double(organization_id: []))
        allow(user).to receive(:can_submit_remote_file?).and_return(true)

        # HEAD: provides Content-Type so RemoteFileInfo derives the extension.
        # GET: serves the cached copy and satisfies any LazyHTTPFile access.
        stub_request(:head, remote_url)
          .to_return(status: 200, headers: { 'Content-Type' => 'image/png' })
        stub_request(:get, remote_url)
          .to_return(body: fixture_content, status: 200)
      end

      it "derives extension from Content-Type, registers ExternalFile, downloads cache, and preserves import_url" do
        described_class.perform_now(file_set, file_info)

        fs = reload_file_set(file_set.id)
        sf = storage_file_for(fs)
        # Cache path uses the original URL basename (no extension), not the enriched label.
        digest     = Digest::SHA256.hexdigest(remote_url)
        cache_path = File.join(working_external_path.to_s, digest, 'opaquefile')
        expect(fs.label).to eq('opaquefile.png')
        expect(fs.title).to include('opaquefile.png')
        expect(fs.import_url).to eq(remote_url)
        expect(File.exist?(cache_path)).to be true
        expect(sf).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(sf.id.to_s).to eq(remote_url)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 4 — remote-backed URL with remote manifest (no local cache copy)
  # ---------------------------------------------------------------------------
  context "scenario 4: remote-backed URL with remote manifest" do
    let(:working_external_path) { Rails.root.join('tmp', 'test_remote_ingest_cache_s4') }
    let(:remote_url) { 'https://remote.example.com/specimens/model.ply' }
    let(:file_info)  { { url: remote_url, file_name: 'model.ply' } }

    let(:file_set) do
      # import_url is set by WorkUploadsHandler before the job runs.
      Hyrax.persister.save(resource: Hyrax::FileSet.new(
        depositor: user.user_key,
        label: 'model.ply',
        title: ['model.ply'],
        import_url: remote_url
      ))
    end

    before do
      FileUtils.mkdir_p(working_external_path)
      allow(Hyrax.config).to receive(:working_external_path)
        .and_return(working_external_path.to_s)

      allow(file_set).to receive(:is_remote_backed?).and_return(true)
      allow(file_set).to receive(:has_remote_manifest?).and_return(true)

      # Stub GET so that LazyHTTPFile can download on-demand (triggered by
      # storage_file_for assertions).  No HEAD needed — no e_tag look-up when
      # the cache file is absent (File.exist? guard in upload_remote_backed).
      stub_request(:get, remote_url)
        .to_return(body: fixture_content, status: 200)
    end

    after { FileUtils.rm_rf(working_external_path) }

    it "registers an ExternalFile, sets label/title/import_url, skips cache, and marks operation successful" do
      described_class.perform_now(file_set, file_info)

      fs = reload_file_set(file_set.id)
      sf = storage_file_for(fs)
      digest     = Digest::SHA256.hexdigest(remote_url)
      cache_path = File.join(working_external_path.to_s, digest, 'model.ply')
      expect(sf).to be_a(Valkyrie::StorageAdapter::ExternalFile)
      expect(sf.id.to_s).to eq(remote_url)
      expect(fs.label).to eq('model.ply')
      expect(fs.title).to include('model.ply')
      expect(fs.import_url).to eq(remote_url)
      expect(File.exist?(cache_path)).to be false
      expect(@operation).to have_received(:success!)
    end
  end
end
