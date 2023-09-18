FactoryBot.define do
  factory :organization_collection, class: OrganizationCollection do

    title               { ["example organization collection"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |organization|
      organization_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS)
      organization.collection_type_gid = organization_collection_type.gid
    end

    after(:create) do |organization|
      # find media_list by id
      ::RSpec::Mocks.allow_message(organization.class, :find).with(organization.id).and_return(organization)
      # find collection by id
      ::RSpec::Mocks.allow_message(::Collection, :find).with(organization.id).and_return(organization)
    end
  end
end