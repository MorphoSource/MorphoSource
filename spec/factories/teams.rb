FactoryBot.define do
  factory :team, class: Collection do
    # Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)

    title               { ["example team"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    collection_type_gid { Hyrax::CollectionType.find_by(machine_id: Morphosource::CollectionTypes::Teams::SETTINGS[:machine_id]).gid }

    after(:create) do |team|
      # find team by id
      ::RSpec::Mocks.allow_message(team.class, :find).with(team.id).and_return(team)
    end
  end
end


