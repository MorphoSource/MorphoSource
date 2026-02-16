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

    # Convenience traits for specific file types
    trait :with_dcm_file do
      with_fixture_file
      fixture_path { 'CMB06020_R-m1_011.dcm' }
    end

    trait :with_ply_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.ply' }
    end

    trait :with_obj_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.obj' }
    end

    trait :with_gltf_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.gltf' }
    end

    trait :with_glb_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.glb' }
    end

    trait :with_glb_complex_file do
      with_fixture_file
      fixture_path { 'whale/whale-mpc-677-150k-4096.glb' }
    end

    trait :with_stl_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.stl' }
    end

    trait :with_wrl_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.wrl' }
    end

    trait :with_x3d_file do
      with_fixture_file
      fixture_path { 'bunny/bunny.x3d' }
    end

    trait :with_docx_file do
      with_fixture_file
      fixture_path { 'bunny/Source.docx' }
    end

    # Archive file traits
    trait :with_dcm_zip do
      with_fixture_file
      fixture_path { 'dcm_stack/dcm_stack.zip' }
    end

    trait :with_dcm_tar do
      with_fixture_file
      fixture_path { 'dcm_stack/dcm_stack.tar' }
    end

    trait :with_obj_zip do
      with_fixture_file
      fixture_path { 'whale/whale-mpc-677-150k-4096-obj.zip' }
    end

    trait :with_obj_tar do
      with_fixture_file
      fixture_path { 'whale/whale-mpc-677-150k-4096-obj.tar' }
    end

    trait :with_gltf_zip do
      with_fixture_file
      fixture_path { 'whale/whale-mpc-677-150k-4096-gltf.zip' }
    end

    trait :with_gltf_tar do
      with_fixture_file
      fixture_path { 'whale/whale-mpc-677-150k-4096-gltf.tar' }
    end

    trait :with_ply_deflate64_zip do
      with_fixture_file
      fixture_path { 'bunny/bunny_deflate64.zip' }
    end
  end
end