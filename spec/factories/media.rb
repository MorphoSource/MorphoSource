FactoryBot.define do
  factory :media, aliases: [:private_media] do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    title { ["example media title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    fileset_visibility { ["restricted"] }
    fileset_accessibility { ["private"] }
    depositor { nil }
  end

  factory :public_media, aliases: [:open_media], :parent => :media do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    fileset_visibility { ["open"] }
    fileset_accessibility { ["open"] }
  end

  factory :restricted_media, :parent => :media do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    fileset_visibility { ["open"] }
    fileset_accessibility { ["restricted_download"] }
  end
end
