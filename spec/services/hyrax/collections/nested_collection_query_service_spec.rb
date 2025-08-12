require 'rails_helper'

RSpec.describe Hyrax::Collections::NestedCollectionQueryService, clean_repo: true do

  # let(:morphosource_query_service)  { Morphosource::Collections::NestedCollectionQueryService }
  # let(:blacklight_config)           { CatalogController.blacklight_config }
  # let(:repository)                  { Blacklight::Solr::Repository.new(blacklight_config) }
  # let(:user)                        { User.create(email: 'user@email.com', password: 'password') }
  # let(:ability)                     { ::Ability.new(user) }
  # let(:current_ability)             { ability }
  # let(:scope)                       { double('Scope', can?: true, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

  # let(:another_collection_type) { Hyrax::CollectionType.create(title: "Another", machine_id: 99) }

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

  before do
    user.confirm
    user.make_contributor
  end

  describe '.parent_collections' do
    subject { described_class.parent_collections(child: child, scope: scope) }

    context 'the collection is not nestable' do
      context 'the collection is a media list' do
        let!(:child) { FactoryBot.create(:media_list_document) }

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end
      context 'the collection is a sequential section list' do
        let!(:child) { FactoryBot.create(:sequential_section_list_document) }

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end

    end
    context 'the collection is nestable' do
      context 'the collection is a team' do
        let!(:child) { FactoryBot.create(:team_document) }

        it 'returns 0 results' do
          expect(subject.response["numFound"]).to eq(0)
        end
      end
      context 'the collection is an organization' do
        let!(:child) { FactoryBot.create(:organization_collection_document) }

        it 'returns 0 results' do
          expect(subject.response["numFound"]).to eq(0)
        end
      end
      context 'the collection is a project' do
        context 'the project is not nested within any collections' do
          let!(:child) { FactoryBot.create(:project_document) }

          it 'returns 0 results' do
            expect(subject.response["numFound"]).to eq(0)
          end
        end
        context 'the project is nested within collections' do
          let!(:parent_team)         { FactoryBot.create(:team_document) }
          let!(:parent_organization) { FactoryBot.create(:organization_collection_document) }
          let!(:child)               { FactoryBot.create(:project_document, "member_of_collection_ids_ssim" => [parent_team.id, parent_organization.id] ) }

          it 'returns the parent collections' do
            expect(subject.response["numFound"]).to eq(2)
            expect(subject.response["docs"].map{|d| d['id']}).to match_array([parent_team.id, parent_organization.id])
          end
        end
      end
    end
  end
end
