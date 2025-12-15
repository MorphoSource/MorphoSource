FactoryBot.define do
  factory :organization_collection, class: OrganizationCollection do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    transient do
      collection_type { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS) }
    end

    title       { ["example organization collection"] }
    depositor   { nil }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    initialize_with do
      new(attributes.merge(collection_type_gid: collection_type.to_global_id))
    end

    after(:build) do |organization|
      # skip creating an example project for tests
      OrganizationCollection.skip_callback(:create, :after, :create_organization_project, raise: false)
    end
  end
end