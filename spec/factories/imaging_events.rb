FactoryBot.define do
  factory :imaging_event do
    title { ["example imaging event title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    ie_modality { ["MagneticResonanceImaging"] }
    physical_object_id { ["000"] }

    after(:create) do |imaging_event|
      # find team by id
      ::RSpec::Mocks.allow_message(imaging_event.class, :find).with(imaging_event.id).and_return(imaging_event)
    end
  end
end