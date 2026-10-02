require 'rails_helper'

RSpec.describe AttachFilesToWorkJob do
  include ActiveJob::TestHelper

  let(:user)  { create(:user) }
  let(:user2) { create(:user) }
  let(:work)  { create(:public_media, depositor: user.user_key) }

  # Use a real fixture file so ValkyrieIngestJob can read and store actual content.
  let(:fixture_file1) { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
  let(:uploaded_file1) { create(:uploaded_file, file: fixture_file1, user: user) }

  before { ActiveJob::Base.queue_adapter = :test }
  after  { fixture_file1.close }

  # ---------------------------------------------------------------------------
  # Valkyrie path
  # ---------------------------------------------------------------------------
  context "when use_valkyrie? is true" do
    before do
      allow(Hyrax.config).to receive(:use_valkyrie?).and_return(true)
      # These jobs require the AF work to exist in Fedora (Wings query path),
      # which the test factory doesn't set up. Stub them out.
      allow(ValkyrieCharacterizationJob).to receive(:perform_later)
      allow(FileSetAttachedEventJob).to receive(:perform_later)
    end

    # Helper: find the Valkyrie FileSets attached to the work after running the job.
    def find_file_sets(work)
      work.reload
      work.valkyrie_member_ids.map { |id| Hyrax.query_service.find_by(id: id) }
    end

    it "creates a FileSet, links FileMetadata, stores a file, sets file_set_uri, and inherits visibility" do
      perform_enqueued_jobs { described_class.perform_now(work, [uploaded_file1]) }

      file_sets = find_file_sets(work)
      expect(file_sets.count).to eq 1
      file_set = file_sets.first
      expect(file_set).to be_a(Hyrax::FileSet)

      file_metadata = Hyrax.custom_queries.find_original_file(file_set: file_set)
      expect(file_metadata).to be_a(Hyrax::FileMetadata)
      expect(file_metadata.file_set_id).to eq file_set.id
      expect(file_metadata.file_identifier).to be_present

      storage_file = Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier)
      expect(storage_file).to be_a(Valkyrie::StorageAdapter::File)

      expect(uploaded_file1.reload.file_set_uri).to be_present
      expect(file_set.visibility).to eq work.visibility
    end

    context "when deposited on behalf of another user (proxy)" do
      before do
        work.on_behalf_of = user2.user_key
        work.save
      end

      it "creates the FileSet under the proxy depositor" do
        described_class.perform_now(work, [uploaded_file1])
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
        described_class.perform_now(work, [uploaded_file1])
        file_set = find_file_sets(work).first
        expect(file_set.depositor).to eq work.depositor
      end
    end

    context "when an uploaded file already has a file_set_uri" do
      let(:uploaded_file1) do
        create(:uploaded_file, file: fixture_file1, user: user,
               file_set_uri: 'http://example.com/existing_file_set')
      end

      it "skips that file" do
        described_class.perform_now(work, [uploaded_file1])
        work.reload
        expect(work.valkyrie_member_ids).to be_empty
      end
    end

    context "when given a non-UploadedFile object" do
      it "raises ArgumentError" do
        expect {
          described_class.perform_now(work, ['not_an_uploaded_file'])
        }.to raise_error(ArgumentError, /Hyrax::UploadedFile required/)
      end
    end
  end

  # ---------------------------------------------------------------------------
  # ActiveFedora path
  # ---------------------------------------------------------------------------
  context "when use_valkyrie? is false" do
    before { allow(Hyrax.config).to receive(:use_valkyrie?).and_return(false) }

    it "creates an AF FileSet and attaches it to the work" do
      described_class.perform_now(work, [uploaded_file1])
      work.reload
      expect(work.file_sets.count).to eq 1
    end

    it "sets the uploaded_file's file_set_uri" do
      described_class.perform_now(work, [uploaded_file1])
      expect(uploaded_file1.reload.file_set_uri).to be_present
    end

    context "when deposited on behalf of another user (proxy)" do
      before do
        work.on_behalf_of = user2.user_key
        work.save
      end

      it "creates the FileSet under the proxy depositor" do
        described_class.perform_now(work, [uploaded_file1])
        work.reload
        expect(work.file_sets.map(&:depositor)).to all(eq user2.user_key)
      end
    end

    context "when deposited as 'Yourself' (blank on_behalf_of)" do
      before do
        work.on_behalf_of = ''
        work.save
      end

      it "uses the work's own depositor" do
        described_class.perform_now(work, [uploaded_file1])
        work.reload
        expect(work.file_sets.map(&:depositor)).to all(eq work.depositor)
      end
    end

    context "when an uploaded file already has a file_set_uri" do
      let(:uploaded_file1) do
        create(:uploaded_file, file: fixture_file1, user: user,
               file_set_uri: 'http://example.com/existing_file_set')
      end

      it "skips that file" do
        described_class.perform_now(work, [uploaded_file1])
        work.reload
        expect(work.file_sets.count).to eq 0
      end
    end

    context "when the work is remote-backed media" do
      before do
        allow(work).to receive(:is_remote_backed?).and_return(true)
      end

      it "creates the AF FileSet with is_remote_backed set on the actor" do
        expect(Hyrax::Actors::FileSetActor).to receive(:new)
          .with(anything, anything, true)
          .and_call_original
        described_class.perform_now(work, [uploaded_file1])
      end
    end

    context "when given a non-UploadedFile object" do
      it "raises ArgumentError" do
        expect {
          described_class.perform_now(work, ['not_an_uploaded_file'])
        }.to raise_error(ArgumentError, /Hyrax::UploadedFile required/)
      end
    end
  end
end
