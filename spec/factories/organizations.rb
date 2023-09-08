FactoryBot.define do
  factory :organization do
    title       { ["example organization title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }

    after(:create) do |organization|
      # find organization by id
      ::RSpec::Mocks.allow_message(organization.class, :find).with(organization.id).and_return(organization)
      ::RSpec::Mocks.allow_message(organization.class, :find).with([organization.id]).and_return([organization])
    end
  end
end