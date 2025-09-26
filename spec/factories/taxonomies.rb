FactoryBot.define do
  # Valkyrie Taxonomy resource work
  factory :taxonomy_resource, class: TaxonomyResource do
    title       { ["example taxonomy title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }
  end

  # ActiveFedora Taxonomy work
  factory :taxonomy, class: Taxonomy do
    # MorphoSource FactoryBehavior methods
    # see config/initializers/factory_bot.rb
    after_create_work # provides find methods for work

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