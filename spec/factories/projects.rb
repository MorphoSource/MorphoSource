FactoryBot.define do
  factory :project, class: Collection do

    title       { ["example project"] }
    depositor   { nil }
    visibility  { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }

    after(:build) do |project|
      project_collection_type = Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS)
      project.collection_type_gid = project_collection_type.gid
    end

    after(:create) do |project|
      # find project by id
      ::RSpec::Mocks.allow_message(project.class, :find).with(project.id).and_return(project)
    end
  end
end


