FactoryBot.define do
  factory :organization do
    title       { ["example organization title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }
  end
end