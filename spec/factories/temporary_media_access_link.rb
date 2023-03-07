FactoryBot.define do
  factory :temporary_media_access_link do
    user { nil }
    media_id { nil }
    expires_at { Time.zone.now + 1.month }
  end
end