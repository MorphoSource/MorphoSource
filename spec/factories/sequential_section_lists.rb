FactoryBot.define do
  factory :sequential_section_list, class: SequentialSectionList do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    title               { ["example sequential section list"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |sequential_section_list|
      sequential_section_list_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
      sequential_section_list.collection_type_gid = sequential_section_list_collection_type.gid
    end
  end
end




