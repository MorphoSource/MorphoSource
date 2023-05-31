FactoryBot.define do
  factory :project, class: Collection do
    title { ["example project"] }
    collection_type_gid { Hyrax::CollectionType.create(title: 'Project').gid }
    depositor { nil }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
  end
end


