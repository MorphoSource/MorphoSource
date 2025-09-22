require 'rails_helper'

RSpec.describe Hyrax::Collections::NestedCollectionQueryService do

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:repository)        { Blacklight::Solr::Repository.new(blacklight_config) }
  let(:user)              { User.create(email:'user@email.com', password: 'password') }
  let(:ability)           { ::Ability.new(user) }
  let(:current_ability)   { ability }
  let(:scope)             { double('Scope', can?: true, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

  describe '.available_project_collections' do
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

    subject { described_class.available_project_collections(parent: parent, scope: scope) }

    describe 'parent is not nestable' do
      let(:parent) { FactoryBot.create(:media_list_document) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is nestable' do
      describe 'user cannot edit the parent' do
        let(:parent) { FactoryBot.create(:team_document) }

        let(:scope) { double('Scope', can?: false, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end

      describe 'user can edit the parent' do
        describe 'parent is not a valid parent collection type' do
        let(:parent) { FactoryBot.create(:project_document, 'edit_access_person_ssim' => [user.ms_id]) }

          it 'returns an empty array' do
            expect(subject).to eq([])
          end
        end

        describe 'parent is a valid parent collection type' do
          it 'returns projects without parents that the user can edit' do
            # parent is a team
            expect(scope).to receive(:can?).with(:edit, team).and_return(true)
            expect(described_class).to receive(:query_solr).with(collection: team, access: :edit, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original

            expect(described_class.available_project_collections(parent: team, scope: scope).map(&:id)).to match_array([projectB.id, projectC.id])

            # parent is an organization
            expect(scope).to receive(:can?).with(:edit, organization).and_return(true)
            expect(described_class).to receive(:query_solr).with(collection: organization, access: :edit, scope: scope, limit_to_id: nil, nest_direction: :as_child).and_call_original

            expect(described_class.available_project_collections(parent: organization, scope: scope).map(&:id)).to match_array([projectB.id, projectC.id])
          end
        end
      end
    end
  end

  describe '.available_parent_collections' do
    let!(:team)                   { FactoryBot.create(:team_document) }
    let!(:organization)           { FactoryBot.create(:organization_collection_document) }
    let!(:editable_team)          { FactoryBot.create(:team_document,
                                                      'edit_access_person_ssim' => [user.ms_id]) }
    let!(:editable_organization)  { FactoryBot.create(:organization_collection_document,
                                                      'edit_access_person_ssim' => [user.ms_id]) }

    subject { described_class.available_parent_collections(child: child, scope: scope) }

    describe 'parent is not nestable' do
      let(:child) { FactoryBot.create(:media_list_document) }

      it 'returns an empty array' do
        expect(subject).to eq([])
      end
    end

    describe 'parent is nestable' do
      describe 'user cannot edit the child' do
        let(:child) { FactoryBot.create(:project_document) }

        let(:scope) { double('Scope', can?: false, current_ability: current_ability, repository: repository, blacklight_config: blacklight_config) }

        it 'returns an empty array' do
          expect(subject).to eq([])
        end
      end
      describe 'user can edit the child' do
        describe 'child is not a valid child collection type' do
        let(:child) { FactoryBot.create(:team_document, 'edit_access_person_ssim' => [user.ms_id]) }

          it 'returns an empty array' do
            expect(subject).to eq([])
          end
        end
        describe 'child is a valid child collection type' do
          describe 'child is a member of a collection' do
            let(:parent)  { FactoryBot.create(:team_document) }
            let(:child)   { FactoryBot.create(:project_document,
                                              'edit_access_person_ssim' => [user.ms_id], 'member_of_collection_ids_ssim' => [parent.id]) }
            it 'returns an empty array' do
              expect(subject).to eq([])
            end
          end
          describe 'child is not a member of a collection' do
            let(:child) { FactoryBot.create(:project_document,
                                            'edit_access_person_ssim' => [user.ms_id]) }
            it 'returns editable teams and organizations' do
              expect(subject).to match_array([editable_team, editable_organization])
            end
          end
        end
      end
    end
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

  describe '.parent_and_child_can_nest?' do
    subject { described_class.parent_and_child_can_nest?(parent: parent, child: child, scope: scope) }

    context 'the parent and child are the same collection' do
      let(:parent) { FactoryBot.create(:team_document) }
      let(:child)  { FactoryBot.create(:team_document) }

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'the parent and child are not the same collection' do
      context 'the child is already nested in a collection' do
        let(:organization)  { FactoryBot.create(:organization_collection_document) }
        let(:parent)        { FactoryBot.create(:team_document) }
        let(:child)         { FactoryBot.create(:project_document, "member_of_collection_ids_ssim" => [organization.id]) }

        it 'returns false' do
          expect(subject).to be false
        end
      end
      context 'the child is not nested in a collection' do
        context 'the parent is an invalid parent collection type' do
          let(:child) { FactoryBot.create(:project_document) }

          context 'the parent is a project' do
            let(:parent) { FactoryBot.create(:project_document) }

            it 'returns false' do
              expect(subject).to be false
            end
          end
          context 'the parent is a media list' do
            let(:parent) { FactoryBot.create(:media_list_document) }

            it 'returns false' do
              expect(subject).to be false
            end
          end
          context 'the parent is a sequential section list' do
            let(:parent) { FactoryBot.create(:sequential_section_list_document) }

            it 'returns false' do
              expect(subject).to be false
            end
          end
        end
        context 'the parent is a valid parent collection type' do
          let(:parent) { FactoryBot.create(:team_document) }
          context 'the child is an invalid child collection type' do
            context 'the child is a team' do
              let(:child) { FactoryBot.create(:team_document) }

              it 'returns false' do
                expect(subject).to be false
              end
            end
            context 'the child is an organization' do
              let(:child) { FactoryBot.create(:organization_collection_document) }

              it 'returns false' do
                expect(subject).to be false
              end
            end
            context 'the child is a media list' do
              let(:child) { FactoryBot.create(:media_list_document) }

              it 'returns false' do
                expect(subject).to be false
              end
            end
            context 'the child is a sequential section list' do
              let(:child) { FactoryBot.create(:sequential_section_list_document) }

              it 'returns false' do
                expect(subject).to be false
              end
            end
          end
          context 'the parent and child are valid collection types' do
            let(:parent)  { FactoryBot.create(:team_document) }
            let(:child)   { FactoryBot.create(:project_document) }
            context 'the parent is not an eligible parent of the child' do
              before do
                allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return([])
              end
              it 'returns false' do
                expect(subject).to be false
              end
            end
            context 'the parent is an available parent of the child' do
              before do
                allow(described_class).to receive(:available_parent_collections).with(child: child, scope: scope, limit_to_id: parent.id).and_return([parent])
              end
              context 'the child is not an eligible child of the parent' do
                before do
                  allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return([])
                end
                it 'returns false' do
                  expect(subject).to be false
                end
              end
              context 'the child is an eligible child of the parent' do

                before do
                  allow(described_class).to receive(:available_child_collections).with(parent: parent, scope: scope, limit_to_id: child.id).and_return([child])
                end
                it 'returns true' do
                  expect(subject).to be true
                end
              end
            end
          end
        end
      end
    end
  end
end
