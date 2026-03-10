require 'rails_helper'

RSpec.describe AttachRemoteFilesToWorkJob do
  include ActiveJob::TestHelper

  let(:user)  { create(:user) }
  let(:user2) { create(:user) }
  let(:work)  { create(:public_media, depositor: user.user_key) }

  let(:remote_url)   { 'https://remote.example.com/specimens/model.ply' }
  let(:remote_files) { [{ url: remote_url, file_name: 'model.ply' }] }

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
      # Stub jobs that require the AF work to exist in Fedora (Wings query path).
      # ValkyrieRemoteIngestJob is enqueued via instance .enqueue (not .perform_later)
      # so it sits in the test queue without executing — no stub needed.
      allow(ValkyrieCharacterizationJob).to receive(:perform_later)
      allow(FileSetAttachedEventJob).to receive(:perform_later)
    end

    it "creates a Valkyrie FileSet with label and import_url, attaches it, and enqueues ValkyrieRemoteIngestJob" do
      described_class.perform_now(work, remote_files)

      file_sets = find_file_sets(work)
      fs = file_sets.first
      expect(file_sets.count).to eq 1
      expect(fs).to be_a(Hyrax::FileSet)
      expect(fs.label).to eq 'model.ply'
      expect(fs.import_url).to eq remote_url
      expect(ValkyrieRemoteIngestJob).to have_been_enqueued
        .with(instance_of(Hyrax::FileSet), remote_files.first)
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

    context "when remote_files is blank" do
      it "returns without creating any FileSets" do
        described_class.perform_now(work, [])
        work.reload
        expect(work.valkyrie_member_ids).to be_empty
      end
    end

    context "when an entry has a blank url" do
      let(:remote_files) { [{ url: '', file_name: 'ignored.ply' }, { url: remote_url, file_name: 'model.ply' }] }

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

    context "when a file:// URL is in a whitelisted ingest dir" do
      let(:fixture_path) { Rails.root.join('spec/fixtures/images/duke.png').to_s }
      let(:remote_files) { [{ url: "file://#{fixture_path}", file_name: 'duke.png' }] }

      before { allow(Hyrax.config).to receive(:whitelisted_ingest_dirs).and_return([Rails.root.join('spec/fixtures').to_s]) }

      it "accepts the file:// URL and creates a FileSet" do
        described_class.perform_now(work, remote_files)
        expect(find_file_sets(work).count).to eq 1
      end
    end
  end

  # ---------------------------------------------------------------------------
  # ActiveFedora path
  # ---------------------------------------------------------------------------
  context "when use_valkyrie? is false" do
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
