# frozen_string_literal: true
require 'rails_helper'

RSpec.describe MigrateExternalFilesToValkyrieJob do
  let(:user)       { create(:user) }
  let(:remote_url) { 'https://remote.example.com/specimens/model.ply' }

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

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
    allow(ValkyrieCharacterizationJob).to receive(:perform_later)
    allow(FileSetAttachedEventJob).to receive(:perform_later)
  end

  # ---------------------------------------------------------------------------
  # Scenario 1 — happy path: registers ExternalFile for a remote-backed FileSet
  # ---------------------------------------------------------------------------
  context "when the FileSet has an import_url" do
    let(:file_set) do
      Hyrax.persister.save(resource: Hyrax::FileSet.new(
        depositor: user.user_key,
        label:     'model.ply',
        title:     ['model.ply'],
        import_url: remote_url
      ))
    end

    it "registers an ExternalFile as the original file with the import_url as ID" do
      described_class.perform_now(file_set)

      fs = reload_file_set(file_set.id)
      sf = storage_file_for(fs)
      fm = original_file_metadata(fs)

      expect(sf).to be_a(Valkyrie::StorageAdapter::ExternalFile)
      expect(sf.id.to_s).to eq remote_url
      expect(fm.original_filename).to eq 'model.ply'
      expect(fm.file_set_id).to eq fs.id
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 2 — idempotency: second call is a no-op
  # ---------------------------------------------------------------------------
  context "when the ExternalFile is already registered" do
    let(:file_set) do
      Hyrax.persister.save(resource: Hyrax::FileSet.new(
        depositor:  user.user_key,
        label:      'model.ply',
        import_url: remote_url
      ))
    end

    before { described_class.perform_now(file_set) }

    it "does not call ValkyrieUpload a second time" do
      expect(Morphosource::ValkyrieUpload).not_to receive(:file)
      described_class.perform_now(file_set)
    end
  end

  # ---------------------------------------------------------------------------
  # Scenario 3 — blank import_url: job returns early
  # ---------------------------------------------------------------------------
  context "when import_url is blank" do
    let(:file_set) do
      Hyrax.persister.save(resource: Hyrax::FileSet.new(
        depositor: user.user_key,
        label:     'model.ply'
      ))
    end

    it "does not call ValkyrieUpload" do
      expect(Morphosource::ValkyrieUpload).not_to receive(:file)
      described_class.perform_now(file_set)
    end
  end
end
