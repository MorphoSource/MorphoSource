require 'rails_helper'

RSpec.describe Morphosource::Dashboard::CollectionMembersController, type: :controller do

  let(:user)                    { User.create(email: 'email@email.com', password: 'password', ms_id: 'abc123') }
  let(:team)                    { FactoryBot.create(:team, title: ['Team'], depositor: user.ms_id) }
  let(:team2)                   { FactoryBot.create(:team, title: ['Team2'], depositor: user.ms_id) }
  let(:work)                    { Media.create(title: ['test work']) }
  let(:ability)                 { Ability.new(user) }
  let(:media_list)              { FactoryBot.create(:media_list, depositor: user.ms_id) }

  before do
    sign_in user
    allow(subject).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:can?).and_call_original
  end

  describe 'updating collection members' do
    describe 'callbacks' do
      context 'collection is a team' do
        before do
          team.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        end
        it 'does not call filter_docs_with_read_access!' do
          expect(subject).not_to receive(:filter_docs_with_read_access!)
          post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
        end
        it 'calls filter_docs_with_edit_access!' do
          expect(subject).to receive(:filter_docs_with_edit_access!)
          post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
        end
      end
      context 'collection is a media list' do
        before do
          media_list.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: media_list)
        end
        it 'does not call filter_docs_with_edit_access!' do
          expect(subject).not_to receive(:filter_docs_with_edit_access!)
          post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
        end
        it 'calls filter_docs_with_read_access!' do
          expect(subject).to receive(:filter_docs_with_read_access!)
          post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
        end
      end
    end

    describe 'adding a single work' do
      context 'collection is a team' do
        before do
          work.edit_users += [user]
          work.save
          team.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        end
        context 'user does not have deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, team).and_return(false)
            allow(ability).to receive(:can?).with(:edit, work.id).and_return(false)
            post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
          end
          it 'does not add the work to the collection' do
            expect(team.member_objects).not_to include(work)
          end
          it 'does not apply permissions to the work' do
            work.reload
            expect(work.read_groups).to match_array([])
            expect(work.download_groups).to match_array([])
            expect(work.edit_groups).to match_array([])
          end
        end
        context 'user has deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, team).and_return(true)
          end
          context 'user does not have edit access for the work' do
            before do
              allow(ability).to receive(:can?).with(:edit, work.id).and_return(false)
            end
            it 'does not add the work to the collection' do
              expect(team.member_objects).not_to include(work)
            end
            it 'does not apply permissions' do
              post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              work.reload
              expect(work.edit_users).to match_array([user.ms_id])
              expect(work.read_groups).to match_array([])
              expect(work.download_groups).to match_array([])
              expect(work.edit_groups).to match_array([])
            end
          end
          context 'user has edit access for the work' do
            before do
              allow(ability).to receive(:can?).with(:edit, work.id).and_return(true)
            end
            context 'work does not belong to another collection' do
              before do
                post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              end
              it 'adds the work to the collection' do
                expect(team.member_objects).to include(work)
              end
              it 'adds the work to the collection with appropriate permissions' do
                work.reload
                expect(work.edit_users).to match_array([user.ms_id])
                expect(work.read_groups).to match_array([team.viewers_group.name])
                expect(work.download_groups).to match_array([team.downloaders_group.name])
                expect(work.edit_groups).to match_array([team.editors_group.name, team.managers_group.name, 'admin'])
              end
            end
            context 'work already belongs to another collection' do
              before do
                team2.create_collection_groups
                Morphosource::Collections::PermissionsCreateService.create_default(collection: team2)
                work.member_of_collections << team2
                Hyrax::PermissionTemplateApplicator.apply(team2.permission_template).to(model: work)
                work.save
                post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              end
              it 'adds the work to the collection' do
                expect(team.member_objects).to match_array([work])
                expect(team2.member_objects).to match_array([work])
                work.reload
                expect(work.member_of_collections).to match_array([team, team2])
              end
              it 'applies appropriate permissions' do
                work.reload
                expect(work.edit_users).to match_array([user.ms_id])
                expect(work.read_groups).to match_array([team.viewers_group.name, team2.viewers_group.name])
                expect(work.download_groups).to match_array([team.downloaders_group.name, team2.downloaders_group.name])
                expect(work.edit_groups).to match_array([team.editors_group.name, team.managers_group.name, team2.editors_group.name, team2.managers_group.name, 'admin'])
              end
            end
          end
        end
      end
      context 'collection is a media list' do
        before do
          work.read_users += [user]
          work.save
          media_list.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: media_list)
        end
        context 'user does not have deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, team).and_return(false)
            post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
          end
          it 'does not add the work to the collection' do
            expect(team.member_objects).not_to include(work)
          end
          it 'does not apply permissions to the work' do
            work.reload
            expect(work.read_groups).to match_array([])
            expect(work.download_groups).to match_array([])
            expect(work.edit_groups).to match_array([])
          end
        end
        context 'user has deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, media_list).and_return(true)
          end
          context 'user has read access only to the work' do
            before do
              allow(ability).to receive(:can?).with(:edit, work).and_return(false)
              allow(ability).to receive(:can?).with(:read, work).and_return(true)
            end
            it 'adds the work to the collection and does not apply additional permissions' do
              post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              work.reload
              expect(media_list.member_objects).to include(work)
              expect(work.edit_users).to match_array([])
              expect(work.read_groups).to match_array([])
              expect(work.download_groups).to match_array([])
              expect(work.edit_groups).to match_array([])
            end
          end
          context 'user has edit access for the work' do
            before do
              allow(ability).to receive(:can?).with(:edit, work).and_return(true)
            end
            context 'work does not belong to another collection' do
              before do
                post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              end
              it 'adds the work to the collection and does not update the work permissions' do
                expect(media_list.member_objects).to include(work)
                work.reload
                expect(work.edit_users).to match_array([])
                expect(work.read_groups).to match_array([])
                expect(work.download_groups).to match_array([])
                expect(work.edit_groups).to match_array([])
              end
            end
            context 'work already belongs to another collection' do
              before do
                team2.create_collection_groups
                Morphosource::Collections::PermissionsCreateService.create_default(collection: team2)
                work.member_of_collections << team2
                Hyrax::PermissionTemplateApplicator.apply(team2.permission_template).to(model: work)
                work.save
                post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id ] }
              end
              it 'adds the work to the collection' do
                expect(media_list.member_objects).to match_array([work])
                expect(team2.member_objects).to match_array([work])
                work.reload
                expect(work.member_of_collections).to match_array([media_list, team2])
              end
              it 'does not apply additional permissions' do
                work.reload
                expect(work.edit_users).to match_array([])
                expect(work.read_groups).to match_array([team2.viewers_group.name])
                expect(work.download_groups).to match_array([team2.downloaders_group.name])
                expect(work.edit_groups).to match_array([team2.editors_group.name, team2.managers_group.name, 'admin'])
              end
            end
          end
        end
      end
    end

    describe 'adding multiple works' do
      let(:work2)   { Media.create(title: ['test work 2']) }
      let(:work3)   { Media.create(title: ['test work 3']) }
      let(:works)   { [work, work2, work3] }

      before do
        works.each{|w| w.edit_users += [user] }
        works.each(&:save)
      end

      context 'collection is a team' do
        before do
          team.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: team)
        end
        context 'user has deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, team).and_return(true)
          end
          context 'user has edit access to all the works' do
            before do
              works.each do |work|
                allow(ability).to receive(:can?).with(:edit, work).and_return(true)
              end
              post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
            end
            it 'adds the works to the collection' do
              expect(team.member_objects).to match_array([work, work2, work3])
              works.each(&:reload)
              works.each do |work|
                expect(work.member_of_collections).to match_array([team])
              end
            end
            it 'applies appropriate permissions' do
              works.each do |work|
                work.reload
                expect(work.edit_users).to match_array([user.ms_id])
                expect(work.read_groups).to match_array([team.viewers_group.name])
                expect(work.download_groups).to match_array([team.downloaders_group.name])
                expect(work.edit_groups).to match_array([team.editors_group.name, team.managers_group.name, 'admin'])
              end
            end
          end
          context 'user has edit access to only one work' do
            before do
              allow(ability).to receive(:can?).with(:edit, work.id).and_return(true)
              [work2, work3].each do |work|
                allow(ability).to receive(:can?).with(:edit, work.id).and_return(false)
              end
              post :update_members, params: { id: team.id, collection: { members: 'add' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
            end
            it 'adds one work to the collection' do
              expect(team.member_objects).to match_array([work])
              work.reload
              expect(work.member_of_collections).to match_array([team])
            end
          end
        end
      end
      context 'collection is a media_list' do
        before do
          media_list.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: media_list)
        end
        context 'user has deposit access to the collection' do
          before do
            allow(ability).to receive(:can?).with(:deposit, media_list).and_return(true)
          end
          context 'user has read access to all the works' do
            before do
              works.each do |work|
                allow(ability).to receive(:can?).with(:read, work).and_return(true)
                allow(ability).to receive(:can?).with(:edit, work).and_return(false)
              end
              post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
            end
            it 'adds the works to the collection' do
              expect(media_list.member_objects).to match_array([work, work2, work3])
              works.each(&:reload)
              works.each do |work|
                expect(work.member_of_collections).to match_array([media_list])
              end
            end
            it 'does not apply any permissions' do
              works.each do |work|
                work.reload
                expect(work.edit_users).to match_array([user.ms_id])
                expect(work.read_groups).to match_array([])
                expect(work.download_groups).to match_array([])
                expect(work.edit_groups).to match_array([])
              end
            end
          end
          context 'user has edit access to only one work, and read access to one work' do
            before do
              # work
              allow(ability).to receive(:can?).with(:read, work.id).and_return(true)
              allow(ability).to receive(:can?).with(:edit, work.id).and_return(true)
              # work2
              allow(ability).to receive(:can?).with(:read, work2.id).and_return(true)
              allow(ability).to receive(:can?).with(:edit, work2.id).and_return(false)
              # work3
              allow(ability).to receive(:can?).with(:read, work3.id).and_return(false)
              allow(ability).to receive(:can?).with(:edit, work3.id).and_return(false)

              post :update_members, params: { id: media_list.id, collection: { members: 'add' }, batch_document_ids: [ work.id, work2.id, work3.id ] }
            end
            it 'adds two works to the collection' do
              expect(media_list.member_objects).to match_array([work, work2])
              work3.reload
              expect(work3.member_of_collections).to match_array([])
            end
          end
        end
      end
    end
  end
end
