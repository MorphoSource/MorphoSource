FactoryBot.define do
  factory :media do
    title { ["example media title"] }
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
    fileset_visibility { [""] }
    fileset_accessibility { ["private"] }
  end

  factory :public_media, :parent => :media do
    visibility { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    fileset_visibility { [""] }
    fileset_accessibility { ["open"] }
  end
end
