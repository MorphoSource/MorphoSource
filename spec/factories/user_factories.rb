FactoryBot.define do
  factory :user do
    sequence(:email)        { |n| "first.last#{n}@example.com" }
    sequence(:ms_id)        { |n| "msid#{n}" }
    sequence(:display_name) { |n| "First Last #{n}"}
    password                {'secret'}

    transient do
      # Allow for custom groups when a user is instantiated.
      # @example create(:user, groups: 'avacado')
      groups { [] }
    end

    after(:build) do |user, evaluator|
      # In case we have the instance but it has not been persisted
      ::RSpec::Mocks.allow_message(user, :groups).and_return(Array.wrap(evaluator.groups))
      # Given that we are stubbing the class, we need to allow for the original to be called
      ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).and_call_original
      # We need to ensure that each instantiation of the admin user behaves as expected.
      # This resolves the issue of both the created object being used as well as re-finding the created object.
      ::RSpec::Mocks.allow_message(user.class.group_service, :fetch_groups).with(user: user).and_return(Array.wrap(evaluator.groups))

      # find user by ms_id
      ::RSpec::Mocks.allow_message(user.class, :find).and_call_original
      ::RSpec::Mocks.allow_message(user.class, :find_by).and_call_original
      ::RSpec::Mocks.allow_message(user.class, :find_by).with(ms_id: user.ms_id).and_return(user)
      # # ms_id is nil
      # ::RSpec::Mocks.allow_message(user.class, :find_by).with(ms_id: nil).and_return(nil)
      # find user by id
      ::RSpec::Mocks.allow_message(user.class, :find).with(user.id).and_return(user)
      # # find user by id
      # ::RSpec::Mocks.allow_message(user.class, :find).with(user.id.to_s).and_return(user)
      # id is nil
      # ::RSpec::Mocks.allow_message(user.class, :find).with(nil).and_return(nil)
    end

    factory :admin do
      groups { ['admin'] }
      after(:build) do |admin|
        role = Role.find_or_create_by(name: "admin")
        role.users << admin
        role.save
      end
    end

    factory :batch_submission_contributor do
      groups { ['batch_submission_contributor', 'contributor'] }
    end

    factory :remote_file_submitter do
      groups { ['remote_file_submitter', 'contributor'] }
    end

    factory :contributor do
      groups { ['contributor'] }
      after(:build) do |contributor|
        role = Role.find_or_create_by(name: "contributor")
        role.users << contributor
        role.save
      end
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
