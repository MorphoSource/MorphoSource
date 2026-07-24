# Generated via
#  `rails generate hyrax:work CulturalHeritageObject`
require 'rails_helper'

RSpec.describe Hyrax::CulturalHeritageObjectsController do
  it 'has curation_concern_type ::CulturalHeritageObject' do
    expect(described_class.curation_concern_type).to be(::CulturalHeritageObject)
  end

  it 'has show_presenter Hyrax::CulturalHeritageObjectPresenter' do
    expect(described_class.show_presenter).to be(Hyrax::CulturalHeritageObjectPresenter)
  end

  describe '#showcase' do
    let(:public_cho)  { CulturalHeritageObject.create(title: ['public cho'], visibility: 'open', vouchered: ['Yes']) }
    let(:private_cho) { CulturalHeritageObject.create(title: ['private cho'], visibility: 'restricted', vouchered: ['Yes']) }
    let(:user)        { User.create(email: 'email@example.com', password: 'password') }

    context 'user is not signed in' do
      context 'work is public' do
        it 'is authorized' do
          get :showcase, params: { id: public_cho.id }
          expect(response.status).to eq(200)
        end
      end
      context 'work is private' do
        it 'it redirects to root with not found flash' do
          get :showcase, params: { id: private_cho.id }
          expect(response.status).to eq(302)
        end
      end
    end
    context 'user is signed in' do
      before do
        sign_in user
      end
      context 'work is public' do
        it 'is authorized' do
          get :showcase, params: { id: public_cho.id }
          expect(response.status).to eq(200)
        end
      end
      context 'work is private' do
        it 'it redirects to root with not found flash' do
          get :showcase, params: { id: private_cho.id }
          expect(response.status).to eq(302)
        end
      end
    end
  end

  describe 'instance methods' do
    let(:cho)       { CulturalHeritageObject.create(title: ['private cho'], visibility: 'restricted', vouchered: ['Yes'], identifier: ['abc123']) }
    let(:user)      { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

    before do
      allow(subject).to receive(:authorize!).with(:update, cho).and_return(true)
      sign_in user
    end

    describe '#update' do
      let(:params)  { { id: cho.id, 'cultural_heritage_object' => { 'identifier' => [cho.identifier.first] } } }
      context 'when it successfully updates' do
        it 'calls #update_media_team_access' do
          expect(subject).to receive(:update_media_team_access)
          expect(subject).to receive(:update_po_team_access)
          patch :update, params: params
        end
      end
    end

    describe '#destroy' do
      before do
        allow(subject).to receive(:authorize!).with(:destroy, cho).and_return(true)
      end

      context 'when the cho has associated media' do
        let(:device)        { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
        let(:imaging_event) { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], physical_object_id: [cho.id], ie_modality: device.modality) }
        let(:media)         { Media.create(title: ['media']) }

        before do
          imaging_event.ordered_members << media
          [cho, imaging_event, media].each(&:save)
          [cho, imaging_event, media].each(&:reload)
        end

        it 'blocks the destroy at the actor-stack level, before the Solr doc is touched' do
          delete :destroy, params: { id: cho.id }
          expect(response).to have_http_status(:no_content)
          expect(CulturalHeritageObject.exists?(cho.id)).to be true
        end
      end

      context 'when the cho has no associated media' do
        it 'destroys the cho normally' do
          delete :destroy, params: { id: cho.id }
          expect(CulturalHeritageObject.exists?(cho.id)).to be false
        end
      end

      context 'when the actor-stack guard misses media that the model-level guard catches' do
        # Exercises the fallback: actor-stack guard (1st call) misses it, before_destroy
        # (2nd call) blocks it -- but only after CleanupFileSetsActor already deleted the
        # Solr doc, since the actor-stack guard is what's supposed to prevent reaching it.
        before do
          allow_any_instance_of(CulturalHeritageObject)
            .to receive(:blocking_media_message)
            .and_return(nil, 'Cannot delete this record while it still has associated media (media-1), which may not be public. Detach or reassign the media first.')
        end

        it 'does not destroy the underlying record, though the response gives no indication' do
          delete :destroy, params: { id: cho.id }
          expect(response).to have_http_status(:no_content)
          # .exists? is Solr-backed; CleanupFileSetsActor deletes the Solr doc before the
          # guard runs, so .find (reads Fedora directly) is what actually proves this.
          expect { CulturalHeritageObject.find(cho.id) }.not_to raise_error
        end
      end
    end

    describe '#update_media_team_access' do
      let(:params)  { { id: cho.id, 'cultural_heritage_object' => { 'identifier' => [cho.identifier.first] } } }
      context "when the cho's params don't include parent organization_id" do
        it 'returns nil for organization_id_param' do
          expect(subject).to receive(:organization_id_param).and_return(nil)
          patch :update, params: params
        end
      end

      context "when the cho's params include parents" do
        let(:media)                 { Media.create(title: ['media']) }
        let(:media2)                { Media.create(title: ['media2']) }
        let(:device)                { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
        let(:imaging_event)         { ImagingEvent.create(title: ['imaging event'], device_id: [device.id.to_s], physical_object_id: [cho.id], ie_modality: device.modality) }
        let(:processing_event)      { ProcessingEvent.create(title: ['processing event']) }
        let(:old_organization)      { Organization.create(title: ['old org'], team_id: [old_team.id]) }
        let(:old_team)              { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
        let(:old_team_manager)      { User.create(email: 'oldmanager@test.com', password: 'password') }
        let(:old_team_depositor)    { User.create(email: 'olddepositor@test.com', password: 'password') }
        let(:old_team_viewer)       { User.create(email: 'oldviewer@test.com', password: 'password') }
        let(:old_team_editor)       { User.create(email: 'oldeditor@test.com', password: 'password') }
        let(:params)                { { id: cho.id, 'cultural_heritage_object' => { 'organization_id' => [parent_organization_id], 'identifier' => [cho.identifier.first] } } }

        before do
          imaging_event.ordered_members << media
          media.ordered_members << processing_event
          processing_event.ordered_members << media2

          cho.organization_id = [old_organization.id]

          old_team.create_collection_groups
          old_team.managers << old_team_manager
          old_team.depositors << old_team_depositor
          old_team.viewers << old_team_viewer
          old_team.user_groups.each(&:save)

          media.read_groups += old_team.user_groups.map(&:name)
          media2.read_groups += old_team.user_groups.map(&:name)

          works = [old_organization, cho, imaging_event, processing_event, media, media2]
          works.each(&:save)
          works.each(&:reload)
        end

        context 'and the parent organization is not changed' do
          let(:parent_organization_id) { old_organization.id }

          before do
            # this will get updated by the actor
            allow(subject).to receive(:new_orgs).and_return([old_organization])
          end

          it 'does not update the media permissions' do
            expect(subject).not_to receive(:update_linked_team_access)
            patch :update, params: params
            expect(subject.send(:organizations_unchanged?)).to be(true)
            [media, media2].each(&:reload)
            # media
            expect(old_team_manager.can?(:read, media)).to be(true)
            expect(old_team_depositor.can?(:read, media)).to be(true)
            expect(old_team_viewer.can?(:read, media)).to be(true)
            # media2
            expect(old_team_manager.can?(:read, media2)).to be(true)
            expect(old_team_depositor.can?(:read, media2)).to be(true)
            expect(old_team_viewer.can?(:read, media2)).to be(true)
          end
        end

        context 'and the parents are changed' do
          let!(:new_organization) { FactoryBot.create(:organization, title: ['new org'], team_id: []) }
          let(:parent_organization_id) { new_organization.id }

          before do
            # this will be updated by the actor
            allow(subject).to receive(:new_orgs).and_return([new_organization])
          end

          context 'and the new organization does not have a linked team' do
            it 'removes read access for the old organization' do
              patch :update, params: params
              [media, media2, cho].each(&:reload)
              # media
              expect(old_team_manager.can?(:read, media)).to be(false)
              expect(old_team_depositor.can?(:read, media)).to be(false)
              expect(old_team_viewer.can?(:read, media)).to be(false)
              # media2
              expect(old_team_manager.can?(:read, media2)).to be(false)
              expect(old_team_depositor.can?(:read, media2)).to be(false)
              expect(old_team_viewer.can?(:read, media2)).to be(false)
              # po read
              expect(old_team_manager.can?(:read, cho)).to be(false)
              expect(old_team_editor.can?(:read, cho)).to be(false)
              # po edit
              expect(old_team_manager.can?(:edit, cho)).to be(false)
              expect(old_team_editor.can?(:edit, cho)).to be(false)
            end
          end

          context 'and the new organization has a linked team' do
            let(:new_team)           { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
            let(:new_team_manager)   { User.create(email: 'newmanager@test.com', password: 'password') }
            let(:new_team_depositor) { User.create(email: 'newdepositor@test.com', password: 'password') }
            let(:new_team_viewer)    { User.create(email: 'newviewer@test.com', password: 'password') }
            let(:new_team_editor)   { User.create(email: 'neweditor@test.com', password: 'password') }

            before do
              new_organization.team_id = [new_team.id]
              new_organization.save
              new_organization.reload

              new_team.create_collection_groups
              new_team.managers << new_team_manager
              new_team.depositors << new_team_depositor
              new_team.viewers << new_team_viewer
              new_team.editors << new_team_editor
              new_team.user_groups.each(&:save)
            end

            it 'removes read and edit access for the old team, and adds read and edit access for the new team' do
              patch :update, params: params
              [media, media2, cho].each(&:reload)
              # media
              expect(old_team_manager.can?(:read, media)).to be(false)
              expect(old_team_depositor.can?(:read, media)).to be(false)
              expect(old_team_viewer.can?(:read, media)).to be(false)
              expect(new_team_manager.can?(:read, media)).to be(true)
              expect(new_team_depositor.can?(:read, media)).to be(true)
              expect(new_team_viewer.can?(:read, media)).to be(true)
              # media2
              expect(old_team_manager.can?(:read, media2)).to be(false)
              expect(old_team_depositor.can?(:read, media2)).to be(false)
              expect(old_team_viewer.can?(:read, media2)).to be(false)
              expect(new_team_manager.can?(:read, media2)).to be(true)
              expect(new_team_depositor.can?(:read, media2)).to be(true)
              expect(new_team_viewer.can?(:read, media2)).to be(true)
              # po read
              expect(old_team_manager.can?(:read, cho)).to be(false)
              expect(old_team_editor.can?(:read, cho)).to be(false)
              expect(new_team_manager.can?(:read, cho)).to be(true)
              expect(new_team_editor.can?(:read, cho)).to be(true)
              expect(new_team_depositor.can?(:read, cho)).to be(false)
              expect(new_team_viewer.can?(:read, cho)).to be(false)
              # po edit
              expect(old_team_manager.can?(:edit, cho)).to be(false)
              expect(old_team_editor.can?(:edit, cho)).to be(false)
              expect(new_team_manager.can?(:edit, cho)).to be(true)
              expect(new_team_editor.can?(:edit, cho)).to be(true)
              expect(new_team_depositor.can?(:edit, cho)).to be(false)
              expect(new_team_viewer.can?(:edit, cho)).to be(false)
            end
          end

        end
      end
    end
  end

end
