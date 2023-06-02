FactoryBot.define do
  factory :media_list, class: MediaList do

    title               { ["example media list"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |media_list|
      media_list_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)
      media_list.collection_type_gid = media_list_collection_type.gid
    end

    after(:create) do |media_list|
      # find media_list by id
      ::RSpec::Mocks.allow_message(media_list.class, :find).with(media_list.id).and_return(media_list)
      # find collection by id
      ::RSpec::Mocks.allow_message(::Collection, :find).with(media_list.id).and_return(media_list)
    end
  end
end


