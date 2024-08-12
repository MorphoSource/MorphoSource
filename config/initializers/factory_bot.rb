module FactoryBehavior
  def after_create_collection
    after(:create) do |collection|
      # find collection with id
      ::RSpec::Mocks.allow_message(collection.class, :find).with(collection.id).and_return(collection)
      # find_by collection with id
      ::RSpec::Mocks.allow_message(collection.class, :find_by).and_call_original
      ::RSpec::Mocks.allow_message(collection.class, :find_by).with(id: collection.id).and_return(collection)
      # find collection by id (Teams and Projects)
      ::RSpec::Mocks.allow_message(Collection, :find).with(collection.id).and_return(collection)
    end
  end

  def after_create_work
    after(:create) do |work|
      # find work with id
      ::RSpec::Mocks.allow_message(ActiveFedora::Base, :find).and_call_original
      ::RSpec::Mocks.allow_message(ActiveFedora::Base, :find).with(work.id).and_return(work)
      ::RSpec::Mocks.allow_message(work.class, :find).and_call_original
      ::RSpec::Mocks.allow_message(work.class, :find).with(work.id).and_return(work)
      ::RSpec::Mocks.allow_message(work.class, :find).with([work.id]).and_return([work])
      # find_by work with id
      ::RSpec::Mocks.allow_message(work.class, :find_by).with(id: work.id).and_return(work)
      # work exists?
      ::RSpec::Mocks.allow_message(work.class, :exists?).with(work.id).and_return(true)
    end
  end
end

class FactoryBot::DefinitionProxy
  include FactoryBehavior
end