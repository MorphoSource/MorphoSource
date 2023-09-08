FactoryBot.define do
  factory :taxonomy, class: Taxonomy do
    title       { ["example taxonomy title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }

    after(:create) do |taxonomy|
      # find taxonomy by id
      ::RSpec::Mocks.allow_message(taxonomy.class, :find).with(taxonomy.id).and_return(taxonomy)
      ::RSpec::Mocks.allow_message(taxonomy.class, :find).with([taxonomy.id]).and_return([taxonomy])
    end
  end
end