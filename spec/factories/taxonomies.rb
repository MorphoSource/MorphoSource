FactoryBot.define do
  # Valkyrie Taxonomy resource work
  factory :taxonomy_resource, class: TaxonomyResource do
    title       { ["example taxonomy title"] }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
    depositor   { nil }

    transient do
      with_index { true }
    end

    after(:create) do |work, evaluator|
      if evaluator.with_index
        work.permission_manager.acl.save
      else
        # manually save acl change_set so it does not automatically index the work
        change_set = work.permission_manager.acl.send(:change_set)
        change_set.sync
        Hyrax.persister.save(resource: change_set.resource)
      end

      Hyrax.index_adapter.save(resource: Hyrax.query_service.find_by(id: work.id)) if evaluator.with_index
    end
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