FactoryBot.define do
  factory :biological_specimen do
    title { ["example specimen title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    vouchered { ['Yes'] }
  end
end