# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ImagingEventResourcesController do
  let(:old_team)         { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
  let(:old_organization) { Organization.create(title: ['old org'], team_id: [old_team.id]) }
  let(:old_specimen)     { BiologicalSpecimen.create(title: ['old specimen'], vouchered: ['Yes'], organization_id: [old_organization.id]) }
  let(:device)           { Device.create(title: ['device'], modality: ['Photogrammetry']) }
  let!(:ie) { FactoryBot.valkyrie_create(:imaging_event_resource, title: ['imaging event'], device: device, physical_object_id: [old_specimen.id], ie_modality: device.modality) }
  let(:user) { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

  before do
    allow(subject).to receive(:authorize!).and_return(true)
    allow(Hyrax.publisher).to receive(:publish)
    sign_in user

    # Stub update_valkyrie_work to simulate a successful Valkyrie update without
    # running form validation or the change_set.update_work transaction.
    allow(subject).to receive(:update_valkyrie_work) do
      subject.send(:after_update_response)
    end
  end

  describe '#update' do
    it 'calls #update_media_team_access on success' do
      expect(subject).to receive(:update_media_team_access)
      patch :update, params: { id: ie.id.to_s }
    end

    context 'with ie_description_delete param' do
      it 'clears the description attachment' do
        expect_any_instance_of(ImagingEventResource).to receive(:description_attachment=).with(nil)
        patch :update, params: { id: ie.id.to_s, ie_description_delete: 'delete' }
      end
    end

    context 'with ie_description param' do
      let(:file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }

      it 'sets the description attachment' do
        expect_any_instance_of(ImagingEventResource).to receive(:description_attachment=).with(instance_of(ActionDispatch::Http::UploadedFile))
        patch :update, params: { id: ie.id.to_s, ie_description: file }
      end
    end

    context 'with ie_reference_delete param' do
      it 'clears the reference attachment' do
        expect_any_instance_of(ImagingEventResource).to receive(:reference_attachment=).with(nil)
        patch :update, params: { id: ie.id.to_s, ie_reference_delete: 'delete' }
      end
    end

    context 'with ie_reference param' do
      let(:file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }

      it 'sets the reference attachment' do
        expect_any_instance_of(ImagingEventResource).to receive(:reference_attachment=).with(instance_of(ActionDispatch::Http::UploadedFile))
        patch :update, params: { id: ie.id.to_s, ie_reference: file }
      end
    end
  end

  describe '#po_changed' do
    before { allow(subject).to receive(:curation_concern).and_return(ie) }

    context 'when physical_object_id param is absent' do
      it 'returns false' do
        subject.params = ActionController::Parameters.new({})
        expect(subject.po_changed).to be(false)
      end
    end

    context 'when physical_object_id is unchanged' do
      it 'returns false' do
        subject.params = ActionController::Parameters.new(
          imaging_event_resource: { physical_object_id: ie.physical_object_id }
        )
        expect(subject.po_changed).to be(false)
      end
    end

    context 'when physical_object_id changes' do
      let(:new_specimen) { BiologicalSpecimen.create(title: ['new'], vouchered: ['Yes']) }

      it 'returns true' do
        subject.params = ActionController::Parameters.new(
          imaging_event_resource: { physical_object_id: [new_specimen.id] }
        )
        expect(subject.po_changed).to be(true)
      end
    end
  end

  describe '#media_owner_update' do
    let(:media) { Media.create(title: ['media']) }

    context 'when the media is a member and the user can edit it' do
      before do
        ie.member_ids = ie.member_ids + [Valkyrie::ID.new(media.id)]
        Hyrax.persister.save(resource: ie)
        allow(subject).to receive(:current_user).and_return(user)
        allow(user).to receive(:can?).with(:edit, media.id).and_return(true)
      end

      it 'calls update' do
        expect(subject).to receive(:update)
        patch :media_owner_update, params: { id: ie.id.to_s, media_id: media.id }
      end
    end

    context 'when the media is not a member' do
      it 'redirects with an unauthorized alert' do
        patch :media_owner_update, params: { id: ie.id.to_s, media_id: 'nonexistent' }
        expect(response).to have_http_status(:redirect)
        expect(flash[:alert]).to eq('Unauthorized.')
      end
    end
  end

  describe '#update_media_team_access' do
    context "when params don't include physical_object_id" do
      it 'does not call update_linked_team_access' do
        expect(subject).not_to receive(:update_linked_team_access)
        patch :update, params: { id: ie.id.to_s }
      end
    end

    context 'when params include physical_object_id' do
      let(:media)              { Media.create(title: ['media']) }
      let(:old_team_manager)   { User.create(email: 'oldmanager@test.com', password: 'password') }
      let(:old_team_depositor) { User.create(email: 'olddepositor@test.com', password: 'password') }
      let(:old_team_viewer)    { User.create(email: 'oldviewer@test.com', password: 'password') }
      let(:params)             { { id: ie.id.to_s, imaging_event_resource: { physical_object_id: [object_id] } } }

      before do
        ie.member_ids = ie.member_ids + [Valkyrie::ID.new(media.id)]
        Hyrax.persister.save(resource: ie)

        old_team.create_collection_groups
        old_team.managers << old_team_manager
        old_team.depositors << old_team_depositor
        old_team.viewers << old_team_viewer
        old_team.user_groups.each(&:save)

        media.read_groups += old_team.user_groups.map(&:name)
        media.save
        media.reload
      end

      context 'and the parent specimen is not changed' do
        let(:object_id) { old_specimen.id }

        before do
          allow(subject).to receive(:new_physical_objects).and_return([old_specimen])
        end

        it 'does not update media permissions' do
          expect(subject).not_to receive(:update_linked_team_access)
          patch :update, params: params
          expect(subject.send(:organizations_unchanged?)).to be(true)
          expect(old_team_manager.can?(:read, media)).to be(true)
          expect(old_team_depositor.can?(:read, media)).to be(true)
          expect(old_team_viewer.can?(:read, media)).to be(true)
        end
      end

      context 'and the specimen is changed' do
        let(:new_organization) { Organization.create(title: ['new org'], team_id: []) }
        let(:new_specimen)     { BiologicalSpecimen.create(title: ['new specimen'], vouchered: ['Yes'], organization_id: [new_organization.id]) }
        let(:new_team)         { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.to_global_id, depositor: user.ms_id) }
        let(:object_id)        { new_specimen.id }

        before do
          allow(subject).to receive(:new_physical_objects).and_return([new_specimen])
        end

        context 'and the new organization does not have a linked team' do
          it 'removes read access for the old organization' do
            patch :update, params: params
            media.reload
            expect(old_team_manager.can?(:read, media)).to be(false)
            expect(old_team_depositor.can?(:read, media)).to be(false)
            expect(old_team_viewer.can?(:read, media)).to be(false)
          end
        end

        context 'and the new organization has a linked team' do
          let(:new_team_manager)   { User.create(email: 'newmanager@test.com', password: 'password') }
          let(:new_team_depositor) { User.create(email: 'newdepositor@test.com', password: 'password') }
          let(:new_team_viewer)    { User.create(email: 'newviewer@test.com', password: 'password') }

          before do
            new_organization.team_id = [new_team.id]
            new_organization.save
            new_organization.reload

            new_team.create_collection_groups
            new_team.managers << new_team_manager
            new_team.depositors << new_team_depositor
            new_team.viewers << new_team_viewer
            new_team.user_groups.each(&:save)
          end

          it 'removes old team access and adds new team access' do
            patch :update, params: params
            expect(old_team_manager.can?(:read, media)).to be(false)
            expect(old_team_depositor.can?(:read, media)).to be(false)
            expect(old_team_viewer.can?(:read, media)).to be(false)
            expect(new_team_manager.can?(:read, media)).to be(true)
            expect(new_team_depositor.can?(:read, media)).to be(true)
            expect(new_team_viewer.can?(:read, media)).to be(true)
          end
        end
      end
    end
  end
end
