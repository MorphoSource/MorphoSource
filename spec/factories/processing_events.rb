FactoryBot.define do
  factory :processing_event do
    title { ["example processing event title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
  end
end