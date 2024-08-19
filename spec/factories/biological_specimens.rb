FactoryBot.define do
  factory :biological_specimen do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    title { ["example specimen title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor { nil }
    vouchered { ['Yes'] }
  end
end