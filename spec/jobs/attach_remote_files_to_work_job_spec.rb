require 'rails_helper'

RSpec.describe AttachRemoteFilesToWorkJob do
  include ActiveJob::TestHelper

  let(:user)  { create(:user) }
  let(:user2) { create(:user) }
  let(:work)  { create(:public_media, depositor: user.user_key) }

  # Use a real fixture file so ValkyrieRemoteIngestJob can read and store actual content.
  let(:fixture_path) { Rails.root.join('spec/fixtures/images/duke.png').to_s }
  let(:remote_url)   { "file://#{fixture_path}" }
  let(:remote_files) { [{ url: remote_url, file_name: 'duke.png' }] }

  before { ActiveJob::Base.queue_adapter = :test }

  # Helper: find Valkyrie FileSets attached to the work.
  def find_file_sets(work)
    work.reload
    work.valkyrie_member_ids.map { |id| Hyrax.query_service.find_by(id: id) }
  end

  # ---------------------------------------------------------------------------
  # Valkyrie path
  # ---------------------------------------------------------------------------
  context "when use_valkyrie? is true" do
    before do
      allow(Hyrax.config).to receive(:use_valkyrie?).and_return(true)
      allow(Hyrax.config).to receive(:whitelisted_ingest_dirs)
        .and_return([Rails.root.join('spec/fixtures').to_s])
      # These jobs require the AF work to exist in Fedora (Wings query path),
      # which the test factory doesn't set up. Stub them out.
      allow(ValkyrieCharacterizationJob).to receive(:perform_later)
      allow(FileSetAttachedEventJob).to receive(:perform_later)
    end

    it "creates a FileSet, links FileMetadata, stores a file, sets label and import_url, and inherits visibility" do
      perform_enqueued_jobs { described_class.perform_now(work, remote_files) }

      file_sets = find_file_sets(work)
      expect(file_sets.count).to eq 1
      file_set = file_sets.first
      expect(file_set).to be_a(Hyrax::FileSet)
      expect(file_set.label).to eq 'duke.png'
      expect(file_set.import_url).to eq remote_url

      file_metadata = Hyrax.custom_queries.find_original_file(file_set: file_set)
      expect(file_metadata).to be_a(Hyrax::FileMetadata)
      expect(file_metadata.file_set_id).to eq file_set.id
      expect(file_metadata.file_identifier).to be_present

      storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
      expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)

      expect(file_set.visibility).to eq work.visibility
    end

    context "when deposited on behalf of another user (proxy)" do
      before do
        work.on_behalf_of = user2.user_key
        work.save
      end

      it "creates the FileSet under the proxy depositor" do
        described_class.perform_now(work, remote_files)
        file_set = find_file_sets(work).first
        expect(file_set.depositor).to eq user2.user_key
      end
    end

    context "when deposited as 'Yourself' (blank on_behalf_of)" do
      before do
        work.on_behalf_of = ''
        work.save
      end

      it "uses the work's own depositor" do
        described_class.perform_now(work, remote_files)
        file_set = find_file_sets(work).first
        expect(file_set.depositor).to eq work.depositor
      end
    end

    context "when remote_files is blank" do
      it "returns without creating any FileSets" do
        described_class.perform_now(work, [])
        work.reload
        expect(work.valkyrie_member_ids).to be_empty
      end
    end

    context "when an entry has a blank url" do
      let(:remote_files) { [{ url: '', file_name: 'ignored.ply' }, { url: remote_url, file_name: 'duke.png' }] }

      it "skips blank entries and attaches only the valid file" do
        described_class.perform_now(work, remote_files)
        expect(find_file_sets(work).count).to eq 1
      end
    end

    context "when an http URL is supplied" do
      let(:remote_files) { [{ url: 'https://valid.example.com/file.ply', file_name: 'file.ply' }] }

      it "accepts http(s) URLs without validation errors" do
        expect { described_class.perform_now(work, remote_files) }.not_to raise_error
      end
    end

    context "when a file:// URL is not in a whitelisted ingest dir" do
      let(:remote_files) { [{ url: 'file:///forbidden/path/file.ply', file_name: 'file.ply' }] }

      before { allow(Hyrax.config).to receive(:whitelisted_ingest_dirs).and_return(['/allowed']) }

      it "raises ArgumentError" do
        expect {
          described_class.perform_now(work, remote_files)
        }.to raise_error(ArgumentError, /doesn't pass validation/)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # ActiveFedora path
  # ---------------------------------------------------------------------------
  context "when use_valkyrie? is false" do
    # AF path routes file:// to IngestLocalFileJob; use https to exercise ImportUrlJob.
    let(:remote_url)   { 'https://remote.example.com/specimens/model.ply' }
    let(:remote_files) { [{ url: remote_url, file_name: 'model.ply' }] }

    before do
      allow(Hyrax.config).to receive(:use_valkyrie?).and_return(false)
      allow(ImportUrlJob).to receive(:perform_later)
      allow(Hyrax::Operation).to receive(:create!).and_return(
        instance_double(Hyrax::Operation, performing!: nil, success!: nil, 'fail!': nil)
      )
    end

    it "creates an AF FileSet and enqueues ImportUrlJob" do
      expect(ImportUrlJob).to receive(:perform_later)
      described_class.perform_now(work, remote_files)
      work.reload
      expect(work.file_sets.count).to eq 1
    end

    it "passes is_remote_backed as a positional argument to FileSetActor (not a keyword)" do
      # Ruby 3.2 raises ArgumentError: unknown keyword: use_valkyrie if the old
      # `use_valkyrie: use_valkyrie` keyword form is used against a positional-only initializer.
      expect(Hyrax::Actors::FileSetActor).to receive(:new) do |_fs, _user, is_remote_backed|
        expect(is_remote_backed).to eq(false)
        actor_double = instance_double(Hyrax::Actors::FileSetActor)
        allow(actor_double).to receive(:create_metadata)
        allow(actor_double).to receive(:attach_to_work)
        actor_double
      end
      described_class.perform_now(work, remote_files)
    end

    context "when deposited on behalf of another user (proxy)" do
      before do
        work.on_behalf_of = user2.user_key
        work.save
      end

      it "creates the AF FileSet under the proxy depositor" do
        described_class.perform_now(work, remote_files)
        work.reload
        expect(work.file_sets.map(&:depositor)).to all(eq user2.user_key)
      end
    end

    context "when a file:// URL is not in a whitelisted ingest dir" do
      let(:remote_files) { [{ url: 'file:///forbidden/path/file.ply', file_name: 'file.ply' }] }

      before { allow(Hyrax.config).to receive(:whitelisted_ingest_dirs).and_return(['/allowed']) }

      it "raises ArgumentError" do
        expect {
          described_class.perform_now(work, remote_files)
        }.to raise_error(ArgumentError, /doesn't pass validation/)
      end
    end
  end
end
