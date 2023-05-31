FactoryBot.define do
  factory :team, class: Collection do
    title { ["example team"] }
    collection_type_gid { Hyrax::CollectionType.create(title: 'Team').gid }
    depositor { nil }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end


