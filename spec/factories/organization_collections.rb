FactoryBot.define do
  factory :organization_collection, class: OrganizationCollection do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_collection # provides find methods for collections

    title               { ["example organization collection"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |organization|
      organization_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
      organization.collection_type_gid = organization_collection_type.gid
      # skip creating an example project for tests
      OrganizationCollection.skip_callback(:create, :after, :create_organization_project, raise: false)
    end
  end
end