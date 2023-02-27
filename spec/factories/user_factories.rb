FactoryBot.define do
  factory :user do
    sequence(:email)        { |n| "first.last#{n}@example.com" }
    sequence(:ms_id)        { |n| "msid_#{n}" }
    sequence(:display_name) { |n| "First Last #{n}"}
    password                {'secret'}

    factory :admin do
      groups { ['admin'] }
    end

    factory :contributor do
      groups { ['contributor'] }
    end

    factory :registered_user do
      groups { ['registered'] }
    end

    trait :guest do
      guest { true }
    end
  end

  factory :confirmed_user, :parent => :user do
    after(:create) { |user| user.confirm }
  end
end
