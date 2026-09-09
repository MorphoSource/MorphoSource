require 'rails_helper'

RSpec.describe MigrateFilesToValkyrieJob do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:content) { File.open(Rails.root.join('spec/fixtures/images/duke.png')) }
  let(:af_file_set) { create(:file_set, user: user, label: 'duke.png', title: ['duke.png'], content: content) }

  # spec/rails_helper.rb registers :test_disk under tmp/, a separate Docker volume from
  # Hyrax.config.fcrepo_binary_directory_path -- hard links can't cross volumes, so that
  # adapter's default file_mover (a plain copy) can't exercise this job's actual behavior.
  # Swap in a VersionedDisk on the same volume, using the real Morphosource::ValkyrieFileMover,
  # for the duration of this spec only.
  around do |example|
    test_path = Rails.root / 'file-storage' / 'migrate_files_to_valkyrie_job_spec_uploads'
    FileUtils.mkdir_p(test_path)
    original_adapter = Valkyrie::StorageAdapter.find(:test_disk)
    Valkyrie::StorageAdapter.register(
      Valkyrie::Storage::Hoard.new(services: [
        Valkyrie::Storage::VersionedDisk.new(base_path: test_path, file_mover: Morphosource::ValkyrieFileMover.method(:call)),
        Valkyrie::Storage::ExternalUrl.new
      ]),
      :test_disk
    )
    example.run
    Valkyrie::StorageAdapter.register(original_adapter, :test_disk)
    FileUtils.rm_rf(test_path)
  end

  after { content.close }

  # The real path Fedora itself stores this file's bytes at, computed the same way
  # the job does (from the fixity digest Fedora already computed for it).
  def fcrepo_disk_path_for(af_file_set)
    digest = af_file_set.original_file.digest.first
    Morphosource::FcrepoBinaryPath.for(digest)
  end

  def migrated_original_file_disk_path(resource)
    file_metadata = Hyrax.custom_queries.find_original_file(file_set: resource)
    Valkyrie.config.storage_adapter.find_by(id: file_metadata.file_identifier).disk_path
  end

  it "hard-links the migrated file to Fedora's own binary instead of copying it" do
    original_path = fcrepo_disk_path_for(af_file_set)
    expect(File.exist?(original_path)).to be true
    original_inode = File.stat(original_path).ino

    ActiveJob::Base.queue_adapter = :test
    allow(Hyrax.config).to receive(:valkyrie_transition?).and_return(true)

    perform_enqueued_jobs(only: [MigrateFilesToValkyrieJob, MigrateExternalFilesToValkyrieJob]) do
      MigrateFileSetToValkyrieJob.perform_now(id: af_file_set.id)
    end

    resource = Hyrax.query_service.find_by(id: af_file_set.id)
    migrated_path = migrated_original_file_disk_path(resource)

    # Same inode == same bytes on disk, zero additional storage used. If this were a
    # byte copy (the bug this job fixes) these would be different inodes.
    expect(File.stat(migrated_path).ino).to eq original_inode
    expect(File.read(migrated_path)).to eq File.read(original_path)

    # Fedora's own copy is untouched -- migration only adds a link, never removes
    # the source (Fedora never deletes binaries; nothing here should either).
    expect(File.exist?(original_path)).to be true
  end
end
