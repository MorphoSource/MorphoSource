FactoryBot.define do
  factory :sequential_section_list, class: SequentialSectionList do
    title { ["example sequential_section_list"] }
    depositor { nil }
    collection_type_gid { nil }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end