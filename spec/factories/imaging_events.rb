FactoryBot.define do
  factory :imaging_event do
    title { ["example imaging event title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    ie_modality { ["MagneticResonanceImaging"] }
    physical_object_id { ["000"] }
  end
end