FactoryBot.define do
  factory :media_list, class: MediaList do
    # Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS)

    title               { ["example media list"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    collection_type_gid { Hyrax::CollectionType.find_by(machine_id: Morphosource::CollectionTypes::MediaLists::SETTINGS[:machine_id]).gid }

    after(:create) do |media_list|
      # find media_list by id
      ::RSpec::Mocks.allow_message(media_list.class, :find).with(media_list.id).and_return(media_list)
      # find collection by id
      ::RSpec::Mocks.allow_message(::Collection, :find).with(media_list.id).and_return(media_list)
    end
  end
end


