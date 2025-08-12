require 'rails_helper'

RSpec.describe Hyrax::Collections::NestedCollectionQueryService, clean_repo: true do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:repository)        { Blacklight::Solr::Repository.new(blacklight_config) }
  let(:user)              { User.create(email:'user@email.com', password: 'password') }
  let(:ability)           { ::Ability.new(user) }
  let(:current_ability)   { ability }
  let!(:contributor_role) { Role.create(name: 'contributor') }
  let(:scope)             { double('Scope',
                                   can?: true,
                                   current_ability: current_ability,
                                   repository: repository,
                                   blacklight_config: blacklight_config) }

  let(:parent) { FactoryBot.create(:team_document) }
  let(:child)  { FactoryBot.create(:project_document) }

  before do
    user.confirm
    user.make_contributor
  end

  describe '.available_child_collections' do
    subject { described_class.available_child_collections(parent: parent, scope: scope, limit_to_id: nil) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:available_project_collections).with(parent: parent, scope: scope, limit_to_id: nil)
      subject
    end
  end

  describe '.available_parent_collections' do
    subject { described_class.available_parent_collections(child: child, scope: scope, limit_to_id: nil) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: nil)
      subject
    end
  end

  describe '.parent_collections' do
    subject { described_class.parent_collections(child: child, scope: scope, page: 1) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:parent_collections).with(child: child, scope: scope, page: 1)
      subject
    end
  end

  describe '.query_solr' do
    subject { described_class.send(:query_solr, collection: child, access: :read, scope: scope, limit_to_id: nil, nest_direction: :parent) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:query_solr).with(collection: child, access: :read, scope: scope, limit_to_id: nil, nest_direction: :parent)
      subject
    end
  end

  describe '.parent_and_child_can_nest?' do
    subject { described_class.parent_and_child_can_nest?(parent: parent, child: child, scope: scope) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:parent_and_child_can_nest?).with(parent: parent, child: child, scope: scope)
      subject
    end
  end

  describe '.nestable?' do
    subject { described_class.send(:nestable?, collection: child) }

    it 'calls the Morphosource service' do
      expect(Morphosource::Collections::NestedCollectionQueryService).to receive(:send).with(:nestable?, collection: child)
      subject
    end
  end
end
