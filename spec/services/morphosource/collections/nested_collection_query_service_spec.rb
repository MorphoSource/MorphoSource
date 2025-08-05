require 'rails_helper'

RSpec.describe Morphosource::Collections::NestedCollectionQueryService do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:repository)        { Blacklight::Solr::Repository.new(blacklight_config) }
  let(:user)              { User.create(email:'user@email.com', password: 'password') }
  let(:ability)           { ::Ability.new(user) }
  let(:current_ability)   { ability }
  let(:scope)             { double('Scope', can?: true, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }
        let!(:contributor_role) { Role.create(name: 'contributor')}


  before do
    user.confirm
    user.make_contributor
  end

  describe '.available_project_collections' do
    subject { described_class.available_project_collections(parent: parent_double, scope: scope) }

    describe 'parent is not nestable' do
      let(:parent_double) { double(nestable?: false, team?: true) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'user cannot edit the parent' do
      let(:parent_double) { double(nestable?: true, team?: true) }

      let(:scope) { double('Scope', can?: false, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is not a team or organization' do
      let(:parent_double) { double(nestable?: true, team?: false, organization_collection?: false) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is nestable, user can edit the parent, and the parent is a team or organization' do


      # let!(:team_collection_type)         { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Teams::SETTINGS)}
      # let!(:organization_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Organizations::SETTINGS) }
      # let!(:project_collection_type)      { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::Projects::SETTINGS) }
      # let(:depositor)                     { FactoryBot.create(:contributor) }



      let(:organization)  { FactoryBot.create(:organization_collection_document) }
      let(:team)          { FactoryBot.create(:team_document) }
      let(:another_team)  { FactoryBot.create(:team_document) }

      let(:projectA)      { FactoryBot.create(:project_document) }
      let(:projectB)      { FactoryBot.create(:project_document,
                                              'edit_access_person_ssim' => [user.ms_id]) }
      let(:projectC)      { FactoryBot.create(:project_document) }
      let(:projectD)      { FactoryBot.create(:project_document,
                                              "member_of_collection_ids_ssim" => [team.id, organization.id] ) }

      let(:collections)   { [organization,team, another_team, projectB, projectC, projectD] }

      before do
        collections.each do |collection|
          Role.create(name: "#{collection.id}_managers", users: [user])
        end
        user.reload
      end

      it 'returns projects without parents that the user can edit' do
        # parent is a team
        # expect(scope).to receive(:can?).with(:edit, team).and_return(true)
        # expect(described_class).to receive(:query_solr).with(collection: team, access: :edit, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original

        # expect(described_class.available_project_collections(parent: team, scope: scope).map(&:id)).to match_array([projectB.id, projectC.id])

        # parent is an organization
        expect(scope).to receive(:can?).with(:edit, organization).and_return(true)
        expect(described_class).to receive(:query_solr).with(collection: organization, access: :edit, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original

        expect(described_class.available_project_collections(parent: organization, scope: scope).map(&:id)).to match_array([projectB.id, projectC.id])
      end
    end
  end
end
