FactoryBot.define do
  factory :temporary_collection_access_link do
    user { nil }
    collection_id { nil }
    expires_at { Time.zone.now + 1.month }
  end
end