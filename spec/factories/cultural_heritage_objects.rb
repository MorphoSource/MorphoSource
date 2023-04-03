FactoryBot.define do
  factory :cultural_heritage_object do
    title { ["example cho title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    vouchered { ['Yes'] }
  end
end