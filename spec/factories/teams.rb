FactoryBot.define do
  factory :team, class: Collection do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    title               { ["example team"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |team|
      team_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)
      team.collection_type_gid = team_collection_type.gid


    end
  end
end


