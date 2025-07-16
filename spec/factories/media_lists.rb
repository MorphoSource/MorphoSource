FactoryBot.define do
  factory :media_list, class: MediaList do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    title               { ["example media list"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |media_list|
      media_list_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
      media_list.collection_type_gid = media_list_collection_type.to_global_id
    end
  end
end


