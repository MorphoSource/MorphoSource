FactoryBot.define do
  factory :sequential_section_list, class: SequentialSectionList do

    title               { ["example sequential section list"] }
    depositor           { nil }
    visibility          { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    collection_type_gid { Hyrax::CollectionType.find_by(machine_id: Morphosource::CollectionTypes::SequentialSectionLists::SETTINGS[:machine_id]).gid }

    after(:create) do |sequential_section_list|
      # find sequential_section_list by id
      ::RSpec::Mocks.allow_message(sequential_section_list.class, :find).with(sequential_section_list.id).and_return(sequential_section_list)
      # find collection by id
      ::RSpec::Mocks.allow_message(::Collection, :find).with(sequential_section_list.id).and_return(sequential_section_list)
    end
  end
end




