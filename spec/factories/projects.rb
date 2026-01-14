FactoryBot.define do
  factory :project, class: Collection do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    transient do
      collection_type { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS) }
    end

    title               { ["example project"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    initialize_with do
      new(attributes.merge(collection_type_gid: collection_type.to_global_id))
    end
  end
end


