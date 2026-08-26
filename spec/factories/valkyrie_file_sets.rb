FactoryBot.define do
  factory :valkyrie_file_set, class: 'Hyrax::FileSet' do
    transient do
      user { FactoryBot.create(:user) }
      title { ['Test FileSet'] }
      files { [] }
    end

    after(:build) do |file_set, evaluator|
      file_set.file_ids = evaluator.files.map(&:id)
    end

    trait :with_fixture_file do
      transient do
        fixture_path { 'bunny/bunny.ply' }
      end

      after(:create) do |file_set, evaluator|
        file_path = Rails.root.join('spec', 'fixtures', evaluator.fixture_path)
        file = File.open(file_path)
        filename = File.basename(file_path)

        # Upload to storage adapter
        saved = Hyrax.storage_adapter.upload(
          resource: file_set,
          file: file,
          original_filename: filename
        )

        # Create FileMetadata
        file_metadata = Hyrax::FileMetadata.new(
          file_identifier: saved.id,
          file_set_id: file_set.id,
          original_filename: filename,
          pcdm_use: [Hyrax::FileMetadata::Use::ORIGINAL_FILE]
        )
        saved_metadata = Hyrax.persister.save(resource: file_metadata)

        # Link to file_set
        file_set.file_ids = [saved_metadata.id]
        Hyrax.persister.save(resource: file_set)

        file.close
      end
    end

    # External URL file trait - creates a FileSet backed by a remote HTTP URL.
    # The file_identifier is set to the URL; no actual upload occurs.
    # Tests should stub the HTTP request via WebMock so LazyHTTPFile
    # downloads fixture content instead of making a real request.
    trait :with_external_file do
      transient do
        remote_url { 'https://remote.example.com/files/test.bin' }
      end

      after(:create) do |file_set, evaluator|
        url = evaluator.remote_url
        filename = File.basename(URI.parse(url).path)

        # Upload via storage adapter - routes to ExternalUrl for https:// URLs
        saved = Hyrax.storage_adapter.upload(
          resource: file_set,
          file: StringIO.new(''),
          original_filename: url
        )

        # Create FileMetadata with URL as file_identifier
        file_metadata = Hyrax::FileMetadata.new(
          file_identifier: saved.id,
          file_set_id: file_set.id,
          original_filename: filename,
          pcdm_use: [Hyrax::FileMetadata::Use::ORIGINAL_FILE]
        )
        saved_metadata = Hyrax.persister.save(resource: file_metadata)

        # Link to file_set
        file_set.file_ids = [saved_metadata.id]
        Hyrax.persister.save(resource: file_set)
      end
    end
  end
end
