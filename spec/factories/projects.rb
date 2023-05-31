FactoryBot.define do
  factory :project, class: Collection do
    # Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS)

    title               { ["example project"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    collection_type_gid { Hyrax::CollectionType.find_by(machine_id: Morphosource::CollectionTypes::Projects::SETTINGS[:machine_id]).gid }

    after(:create) do |project|
      # find team by id
      ::RSpec::Mocks.allow_message(project.class, :find).with(project.id).and_return(project)
    end
  end
end


