FactoryBot.define do
  factory :team, class: Collection do

    title       { ["example team"] }
    depositor   { nil }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |team|
      team_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)
      team.collection_type_gid = team_collection_type.gid
    end

    after(:create) do |team|
      # find team by id
      ::RSpec::Mocks.allow_message(team.class, :find).with(team.id).and_return(team)
    end
  end
end


