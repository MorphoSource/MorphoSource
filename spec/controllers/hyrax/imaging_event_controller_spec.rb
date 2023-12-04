# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ImagingEventsController do
  let(:old_team)              { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:old_organization)      { Organization.create(title: ['old org'], team_id: [old_team.id]) }
  let(:old_specimen)          { BiologicalSpecimen.create(title: ['old specimen'], vouchered: ["Yes"], organization_id: [old_organization.id]) }
  let(:device)                { Device.create(title: ['device'], modality: ['Photogrammetry'])}
  let!(:imaging_event)        { ImagingEvent.create(title: ['imaging event'], device_id: [device.id], physical_object_id: [old_specimen.id], ie_modality: device.modality) }
  let(:user)                  { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

  before do
    allow(subject).to receive(:authorize!).with(:update, imaging_event).and_return(true)

    sign_in user
  end

  describe '#update' do
    context 'when imaging_event_modality_valid? and actor.update(actor_environment) are both true' do
      it 'calls #update_media_team_access' do
        expect(subject).to receive(:update_media_team_access)
        patch :update, params: { id: imaging_event.id }
      end
    end
  end

  describe '#update_media_team_access' do
    context "when the imaging event's params don't include parents" do
      it 'returns nil for parents_attributes' do
        expect(subject).to receive(:parents_attributes).and_return(nil)
        patch :update, params: { id: imaging_event.id }
      end
    end

    context "when the imaging event's params include physical_object_id" do
      let(:media)                 { Media.create(title: ['media']) }
      let(:old_team_manager)      { User.create(email: 'oldmanager@test.com', password: 'password') }
      let(:old_team_depositor)    { User.create(email: 'olddepositor@test.com', password: 'password') }
      let(:old_team_viewer)       { User.create(email: 'oldviewer@test.com', password: 'password') }
      let(:params)                { { id: imaging_event.id, 'imaging_event' => { 'physical_object_id' => [object_id] } } }

      before do
        imaging_event.ordered_members << media

        old_team.create_collection_groups
        old_team.managers << old_team_manager
        old_team.depositors << old_team_depositor
        old_team.viewers << old_team_viewer
        old_team.user_groups.each(&:save)

        media.read_groups += old_team.user_groups.map(&:name)

        works = [imaging_event, media]
        works.each(&:save)
        works.each(&:reload)
      end

      context 'and the parent specimen is not changed' do
        let(:object_id) { old_specimen.id }

        before do
          # this will get updated by the actor
          allow(subject).to receive(:new_physical_objects).and_return([old_specimen])
        end

        it 'does not update the media permissions' do
          expect(subject).not_to receive(:update_linked_team_access)
          patch :update, params: params
          expect(subject.send(:organizations_unchanged?)).to be(true)
          expect(old_team_manager.can?(:read, media)).to be(true)
          expect(old_team_depositor.can?(:read, media)).to be(true)
          expect(old_team_viewer.can?(:read, media)).to be(true)
        end
      end

      context 'and the objectss are changed' do
        let(:new_organization)  { Organization.create(title: ['new org'], team_id: []) }
        let(:new_specimen)      { BiologicalSpecimen.create(title: ['new specimen'], vouchered: ["Yes"], organization_id: [new_organization.id]) }
        let(:new_team)          { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

        let(:object_id)         { new_specimen.id }

        before do
          # this will be updated by the actor
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

          it 'removes read access for the old team, and adds read access for the new team' do
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
