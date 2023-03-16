FactoryBot.define do
  factory :media_list, class: MediaList do
    title { ["example media_list"] }
    depositor { nil }
    collection_type_gid { nil }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end