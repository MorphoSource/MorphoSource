require 'rails_helper'

RSpec.describe MigrateFileSetToValkyrieJob do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }

  # Helpers -----------------------------------------------------------------

  def postgres_record_for(id)
    Hyrax.query_service.postgres_service.find_by(id: id.to_s)
  end

  def valkyrie_file_set_for(id)
    Hyrax.query_service.find_by(id: id)
  end

  before do
    ActiveJob::Base.queue_adapter = :test
    # FreyjaWithWings persister auto-enqueues MigrateFilesToValkyrieJob only
    # when valkyrie_transition? is true. VALKYRIE_TRANSITION=true in the Docker
    # env already sets this, but we stub here for clarity.
    allow(Hyrax.config).to receive(:valkyrie_transition?).and_return(true)
  end

  # ---------------------------------------------------------------------------
  # plain AF FileSet (no file content)
  # ---------------------------------------------------------------------------
  context "plain AF FileSet with no file content" do
    let(:af_file_set) { create(:file_set, user: user, label: 'test.ply', title: ['test.ply']) }

    it "creates a non-Wings Postgres record preserving label, title, and depositor" do
      expect { postgres_record_for(af_file_set.id) }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      described_class.perform_now(id: af_file_set.id)

      fs = valkyrie_file_set_for(af_file_set.id)
      expect(postgres_record_for(af_file_set.id)).to be_present
      expect(fs).not_to be_wings
      expect(fs.label).to eq 'test.ply'
      expect(fs.title).to include('test.ply')
      expect(fs.depositor).to eq user.user_key
    end
  end

  # ---------------------------------------------------------------------------
  # AF FileSet with real file content enqueues appropriate job
  # ---------------------------------------------------------------------------
  context "AF FileSet with file content stored in Fedora" do
    let(:content)    { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
    let(:af_file_set) { create(:file_set, user: user, label: 'duke.png', title: ['duke.png'], content: content) }

    after { content.close }

    it "enqueues MigrateFilesToValkyrieJob for the fedora-backed file" do
      expect { described_class.perform_now(id: af_file_set.id) }
        .to have_enqueued_job(MigrateFilesToValkyrieJob)
    end
  end

  # ---------------------------------------------------------------------------
  # parent work membership update
  # ---------------------------------------------------------------------------
  context "AF FileSet attached to an AF work" do
    let(:work) { create(:public_media, depositor: user.user_key) }
    let(:af_file_set) do
      fs = create(:file_set, user: user, label: 'scan.ply', title: ['scan.ply'])
      work.ordered_members << fs
      work.save!
      fs
    end

    it "adds the migrated FileSet ID to the parent work's valkyrie_member_ids" do
      described_class.perform_now(id: af_file_set.id)
      work.reload
      expect(work.valkyrie_member_ids).to include(af_file_set.id)
    end
  end

  # ---------------------------------------------------------------------------
  # idempotency: already-migrated FileSet is skipped
  # ---------------------------------------------------------------------------
  context "when the FileSet has already been migrated to Valkyrie" do
    let(:af_file_set) { create(:file_set, user: user, title: ['scan.ply']) }

    before { described_class.perform_now(id: af_file_set.id) }

    it "does not call MigrateResourceService a second time" do
      expect(MigrateResourceService).not_to receive(:new)
      described_class.perform_now(id: af_file_set.id)
    end
  end

  # ---------------------------------------------------------------------------
  # FileSet not found
  # ---------------------------------------------------------------------------
  context "when the FileSet ID does not exist" do
    it "logs a warning and does not raise" do
      expect { described_class.perform_now(id: 'nonexistent000') }.not_to raise_error
    end
  end

  # ---------------------------------------------------------------------------
  # remote-backed FileSet (custom MorphoSource properties)
  # ---------------------------------------------------------------------------
  context "AF FileSet with remote-backed custom properties" do
    let(:af_file_set) do
      fs = create(:file_set, user: user, label: 'model.ply', title: ['model.ply'])
      fs.import_url          = 'https://remote.example.com/model.ply'
      fs.mime_type_of_remote = 'model/ply'
      fs.digest              = 'abc123sha1'
      fs.e_tag               = '"etag-xyz"'
      fs.accessibility       = ['open']
      fs.save!
      fs
    end

    it "preserves label, title, import_url, and all custom MorphoSource properties after migration" do
      described_class.perform_now(id: af_file_set.id)

      fs = valkyrie_file_set_for(af_file_set.id)
      expect(fs).not_to be_wings
      expect(fs.label).to eq 'model.ply'
      expect(fs.title).to include('model.ply')
      expect(fs.import_url).to eq 'https://remote.example.com/model.ply'
      expect(fs.mime_type_of_remote).to eq 'model/ply'
      expect(fs.digest).to eq 'abc123sha1'
      expect(fs.e_tag).to eq '"etag-xyz"'
      expect(fs.accessibility).to eq ['open']
    end

    context "when attached to a parent work" do
      let(:work) { create(:public_media, depositor: user.user_key) }

      before do
        work.ordered_members << af_file_set
        work.save!
      end

      it "updates parent valkyrie_member_ids and preserves properties" do
        described_class.perform_now(id: af_file_set.id)

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs.mime_type_of_remote).to eq 'model/ply'
      end
    end
  end

  describe "full migration chain by realistic file-origin scenario" do
    # Local upload: real Fedora binary, no import_url, not remote-backed.
    context "scenario 0: local web UI upload" do
      let(:content) { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
      let(:work) { create(:public_media, depositor: user.user_key) }
      let(:af_file_set) do
        fs = create(:file_set, user: user, label: 'upload.png', title: ['upload.png'], content: content)
        work.ordered_members << fs
        work.save!
        fs
      end

      after { content.close }

      it "migrates to a local-disk-backed Hyrax::FileSet with no import_url and is_remote_backed? false" do
        perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
          described_class.perform_now(id: af_file_set.id)
        end

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs).not_to be_wings
        expect(fs.import_url).to be_blank
        expect(fs.is_remote_backed?).to be false

        file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
        storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
        expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)
        expect(File.exist?(storage_file.disk_path)).to eq true
      end
    end

    # BrowseEverything Globus file: real Fedora binary, import_url is a local path.
    context "scenario 1: local secondary-source file (Globus)" do
      let(:content) { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
      let(:work) { create(:public_media, depositor: user.user_key) }
      let(:af_file_set) do
        fs = create(:file_set, user: user, label: 'globus_scan.png', title: ['globus_scan.png'], content: content)
        fs.import_url = '/mnt/globus/incoming/globus_scan.png'
        fs.save!
        work.ordered_members << fs
        work.save!
        fs
      end

      after { content.close }

      it "migrates to a local-disk-backed Hyrax::FileSet preserving the local import_url and is_remote_backed? false" do
        perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
          described_class.perform_now(id: af_file_set.id)
        end

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs).not_to be_wings
        expect(fs.import_url).to eq '/mnt/globus/incoming/globus_scan.png'
        expect(fs.is_remote_backed?).to be false

        file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
        storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
        expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)
      end
    end

    # BrowseEverything URL: real Fedora binary, import_url is the remote URL.
    context "scenario 2: BrowseEverything URL ingested locally" do
      let(:content) { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
      let(:work) { create(:public_media, depositor: user.user_key) }
      let(:af_file_set) do
        fs = create(:file_set, user: user, label: 'downloaded_scan.png', title: ['downloaded_scan.png'], content: content)
        fs.import_url = 'https://browse-everything.example.com/downloaded_scan.png'
        fs.save!
        work.ordered_members << fs
        work.save!
        fs
      end

      after { content.close }

      it "migrates to a local-disk-backed Hyrax::FileSet preserving the remote import_url and is_remote_backed? false" do
        perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
          described_class.perform_now(id: af_file_set.id)
        end

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs).not_to be_wings
        expect(fs.import_url).to eq 'https://browse-everything.example.com/downloaded_scan.png'
        expect(fs.is_remote_backed?).to be false

        file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
        storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
        expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)
      end
    end

    # Remote-backed media: no Fedora binary, Media.remote_origin_url is set on a real parent.
    context "scenario 3: remote-backed media with temp cache copy" do
      let(:remote_url) { 'https://remote.example.com/model.ply' }
      let(:work) do
        m = create(:public_media, depositor: user.user_key)
        m.remote_origin_url = remote_url
        m.save!
        m
      end
      let(:af_file_set) do
        fs = create(:file_set, user: user, label: 'model.ply', title: ['model.ply'])
        fs.import_url = remote_url
        fs.save!
        work.ordered_members << fs
        work.save!
        fs
      end

      it "confirms is_remote_backed? is true pre-migration via the real Media parent" do
        expect(af_file_set.is_remote_backed?).to be true
      end

      it "migrates to an ExternalFile-backed Hyrax::FileSet pointing at the remote URL" do
        perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
          described_class.perform_now(id: af_file_set.id)
        end

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs).not_to be_wings
        expect(fs.import_url).to eq remote_url
        expect(fs.is_remote_backed?).to be true

        file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
        expect(file_metadata).to be_a(Hyrax::FileMetadata)

        storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
        expect(storage_file).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(storage_file.id.to_s).to eq remote_url
      end
    end

    # Same as scenario 3, plus Media.remote_manifest_url set on the real parent.
    context "scenario 4: remote-backed media with remote manifest, no temp copy" do
      let(:remote_url) { 'https://remote.example.com/model.ply' }
      let(:manifest_url) { 'https://remote.example.com/iiif/manifest.json' }
      let(:work) do
        m = create(:public_media, depositor: user.user_key)
        m.remote_origin_url = remote_url
        m.remote_manifest_url = manifest_url
        m.save!
        m
      end
      let(:af_file_set) do
        fs = create(:file_set, user: user, label: 'model.ply', title: ['model.ply'])
        fs.import_url = remote_url
        fs.save!
        work.ordered_members << fs
        work.save!
        fs
      end

      it "confirms is_remote_backed? and has_remote_manifest? are true pre-migration via the real Media parent" do
        expect(af_file_set.is_remote_backed?).to be true
        expect(af_file_set.has_remote_manifest?).to be true
      end

      it "migrates to an ExternalFile-backed Hyrax::FileSet without downloading a local cache copy" do
        perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
          described_class.perform_now(id: af_file_set.id)
        end

        work.reload
        expect(work.valkyrie_member_ids).to include(af_file_set.id)

        fs = valkyrie_file_set_for(af_file_set.id)
        expect(fs).not_to be_wings
        expect(fs.import_url).to eq remote_url
        expect(fs.is_remote_backed?).to be true
        expect(fs.has_remote_manifest?).to be true

        file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
        expect(file_metadata).to be_a(Hyrax::FileMetadata)

        storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
        expect(storage_file).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(storage_file.id.to_s).to eq remote_url
      end
    end
  end
end
