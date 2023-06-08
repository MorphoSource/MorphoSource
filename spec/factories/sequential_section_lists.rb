FactoryBot.define do
  factory :sequential_section_list, class: SequentialSectionList do

    title       { ["example sequential section list"] }
    depositor   { nil }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |sequential_section_list|
      sequential_section_list_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS)
      sequential_section_list.collection_type_gid = sequential_section_list_collection_type.gid
    end

    after(:create) do |sequential_section_list|
      # find sequential_section_list by id
      ::RSpec::Mocks.allow_message(sequential_section_list.class, :find).with(sequential_section_list.id).and_return(sequential_section_list)
      # find collection by id
      ::RSpec::Mocks.allow_message(::Collection, :find).with(sequential_section_list.id).and_return(sequential_section_list)
    end
  end
end




