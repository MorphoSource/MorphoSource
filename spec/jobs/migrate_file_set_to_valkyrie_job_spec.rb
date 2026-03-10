require 'rails_helper'

# todo: add scenarios for AF files with various remote-backed arrangements

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
  # Scenario 1 — plain AF FileSet (no file content)
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
  # Scenario 2 — AF FileSet with real file content (full migration chain)
  # ---------------------------------------------------------------------------
  context "AF FileSet with file content stored in Fedora" do
    let(:content)    { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
    let(:af_file_set) { create(:file_set, user: user, label: 'duke.png', title: ['duke.png'], content: content) }

    after { content.close }

    it "enqueues MigrateFilesToValkyrieJob for the fedora-backed file" do
      expect { described_class.perform_now(id: af_file_set.id) }
        .to have_enqueued_job(MigrateFilesToValkyrieJob)
    end

    it "produces a FileMetadata record and a real storage file after the full chain" do
      # perform_enqueued_jobs auto-runs MigrateFilesToValkyrieJob when it is
      # enqueued inside the block (by the Freyja persister hook).
      perform_enqueued_jobs(only: MigrateFilesToValkyrieJob) do
        described_class.perform_now(id: af_file_set.id)
      end

      fs = valkyrie_file_set_for(af_file_set.id)
      expect(fs).not_to be_wings
      expect(fs.label).to eq "duke.png"
      expect(fs.title).to include("duke.png")

      file_metadata = Hyrax.custom_queries.find_original_file(file_set: fs)
      expect(file_metadata).to be_a(Hyrax::FileMetadata)
      expect(file_metadata.file_set_id).to eq fs.id
      expect(file_metadata.file_identifier).to be_present

      storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
      expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)
      expect(storage_file.disk_path).to be_present
      expect(File.exist?(storage_file.disk_path)).to eq true
      expect(File.basename(storage_file.disk_path)).to include("duke.png") # versioneddisk appends other info to file name
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 3 — parent work membership update
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
  # Scenario 4 — idempotency: already-migrated FileSet is skipped
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
  # Scenario 5 — FileSet not found
  # ---------------------------------------------------------------------------
  context "when the FileSet ID does not exist" do
    it "logs a warning and does not raise" do
      expect { described_class.perform_now(id: 'nonexistent000') }.not_to raise_error
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 6 — remote-backed FileSet (custom MorphoSource properties)
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

    context "when is_remote_backed? is true" do
      before do
        allow_any_instance_of(Hyrax::FileSet).to receive(:is_remote_backed?).and_return(true)
      end

      it "enqueues MigrateExternalFilesToValkyrieJob for the remote-backed file" do
        expect { described_class.perform_now(id: af_file_set.id) }
          .to have_enqueued_job(MigrateExternalFilesToValkyrieJob)
      end

      it "produces an ExternalFile as the original file after the full chain" do
        perform_enqueued_jobs(only: MigrateExternalFilesToValkyrieJob) do
          described_class.perform_now(id: af_file_set.id)
        end

        fs = valkyrie_file_set_for(af_file_set.id)
        fm = Hyrax.custom_queries.find_original_file(file_set: fs)
        sf = Valkyrie.config.storage_adapter.find_by(id: fm.file_identifier)

        expect(sf).to be_a(Valkyrie::StorageAdapter::ExternalFile)
        expect(sf.id.to_s).to eq 'https://remote.example.com/model.ply'
        expect(fm.original_filename).to eq 'model.ply'
        expect(fm.file_set_id).to eq fs.id
      end
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
end
