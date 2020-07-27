require 'rails_helper'

RSpec.describe Hyrax::Dashboard::CollectionsController, type: :controller do
  routes { Hyrax::Engine.routes }

  let(:user)                  { User.create(email: 'email@email.com', password: 'password') }
  let(:team_collection_type)  { Hyrax::CollectionType.create(Morphosource::CollectionTypes::Teams::SETTINGS) }
  let(:team)                  { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:team2) { Collection.create(title: ['Team2'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  let(:work)                  { Media.create(title: ['Test Work'], depositor: user.ms_id) }
  let(:ability)               { Ability.new(user) }

  before do
    allow(subject.current_user).to receive(:user?).and_return(true)
    sign_in user
    team.create_collection_groups
    Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
    work.member_of_collections << team
    Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: work)
    work.edit_users += [user.ms_id]
    work.save
    allow(subject).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:can?).and_call_original
  end

  describe 'update' do
    before do
      allow(ability).to receive(:can?).with(:update, team).and_return(true)
      allow(ability).to receive(:can?).with(:edit, work.id).and_return(true)
    end

    describe 'callbacks' do
      it 'does not call filter_docs_with_read_access!' do
        expect(subject).not_to receive(:filter_docs_with_read_access!)
        put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
      end
      it 'calls filter_docs_with_edit_access!' do
        expect(subject).to receive(:filter_docs_with_edit_access!)
        put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
      end
    end
    
    describe 'removing works from the collection' do
      context 'removing a single work' do
        before do
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
        end

        it 'removes the association' do
          work.reload
          expect(team.member_objects).not_to include(work)
          expect(work.member_of_collections).not_to include(team)
        end

        it 'removes team permissions' do
          work.reload
          expect(work.edit_users).to match_array([user.ms_id])
          expect(work.read_groups).to match_array([])
          expect(work.download_groups).to match_array([])
          expect(work.edit_groups).to match_array(['admin'])
        end
      end

      context 'the work is in another collection' do
        before do
          team2.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team2)
          work.member_of_collections << team2
          Hyrax::PermissionTemplateApplicator.apply(team2.permission_template).to(model: work)
          work.save
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id ] }
        end

        it 'removes the association' do
          work.reload
          expect(team.member_objects).not_to include(work)
          expect(team2.member_objects).to include(work)
          expect(work.member_of_collections).not_to include(team)
          expect(work.member_of_collections).to include(team2)
        end

        it "removes only one team's permissions" do
          work.reload
          expect(work.edit_users).to match_array([user.ms_id])
          expect(work.read_groups).to match_array([team2.viewers_group.name])
          expect(work.download_groups).to match_array([team2.downloaders_group.name])
          expect(work.edit_groups).to match_array([ team2.editors_group.name, team2.managers_group.name, 'admin'])
        end
      end
    end

    context 'removing multiple works' do
      let(:work2) { Media.create(title: ['Test Work 2'], depositor: user.ms_id) }
      let(:work3) { Media.create(title: ['Test Work 3'], depositor: user.ms_id) }
      let(:works) { [work, work2, work3] }

      before do
        [work2, work3].each do |w|
          w.member_of_collections << team
          w.edit_users += [user.ms_id]
          Hyrax::PermissionTemplateApplicator.apply(team.permission_template).to(model: w)
          w.save
        end
      end

      context 'the works belong to one collection' do
        before do
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
        end
        it 'removes the association' do
          works.each(&:reload)
          works.each do |w|
            expect(team.member_objects).not_to include(w)
            expect(w.member_of_collections).not_to include(team)
          end
        end

        it 'removes team permissions' do
          works.each(&:reload)
          works.each do |w|
            expect(w.edit_users).to match_array([user.ms_id])
            expect(w.read_groups).to match_array([])
            expect(w.download_groups).to match_array([])
            expect(w.edit_groups).to match_array(['admin'])
          end
        end
      end

      context 'the works belong to another collection' do
        before do
          team2.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team2)
          works.each do |w|
            w.member_of_collections << team2
            Hyrax::PermissionTemplateApplicator.apply(team2.permission_template).to(model: w)
            w.save
          end
          put :update, params: { id: team.id, collection: { members: 'remove' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
        end
        it 'removes the association' do
          works.each(&:reload)
          works.each do |w|
            expect(team.member_objects).not_to include(w)
            expect(w.member_of_collections).not_to include(team)
          end
        end

        it "removes only one team's permissions" do
          works.each(&:reload)
          works.each do |w|
            expect(w.edit_users).to match_array([user.ms_id])
            expect(w.read_groups).to match_array([team2.viewers_group.name])
            expect(w.download_groups).to match_array([team2.downloaders_group.name])
            expect(w.edit_groups).to match_array([ team2.editors_group.name, team2.managers_group.name, 'admin'])
          end
        end
      end
    end
  end
end
