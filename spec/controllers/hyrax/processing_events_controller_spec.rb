# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work ProcessingEvent`
require 'rails_helper'

RSpec.describe Hyrax::ProcessingEventsController do
  describe 'class' do
    it "should have curation_concern_type ::ProcessingEvent" do
      expect(Hyrax::ProcessingEventsController.curation_concern_type).to be(::ProcessingEvent)
    end
    it "should have show_presenter Hyrax::ProcessingEventPresenter" do
      expect(Hyrax::ProcessingEventsController.show_presenter).to be(Hyrax::ProcessingEventPresenter)
    end
  end

  describe 'instance methods' do
    let(:actor)             { double(update: true) }
    let!(:processing_event) { ProcessingEvent.create(title: ['processing event']) }
    let(:user)              { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

    before do
      allow(subject).to receive(:actor).and_return(actor)
      allow(subject).to receive(:authorize!).with(:update, processing_event).and_return(true)

      sign_in user
    end

    describe '#update' do
      it 'calls #update_media_team_access' do
        expect(subject).to receive(:update_media_team_access)
        patch :update, params: { id: processing_event.id }
      end
    end

    describe '#update_media_team_access' do
      context "when the processing event's params don't include parents" do
        it 'returns nil for parents_attributes' do
          expect(subject).to receive(:parents_attributes).and_return(nil)
          patch :update, params: { id: processing_event.id }
        end
      end

      context "when the processing event's params include parents" do
        let(:media)                 { Media.create(title: ['media']) }
        let(:device)                { Device.create(title: ['device'], modality: ['Photogrammetry']) }
        let(:imaging_event)         { ImagingEvent.create(title: ['imaging event'], device_id: [device.id], ie_modality: device.modality) }
        let(:old_specimen)          { BiologicalSpecimen.create(title: ['old specimen'], vouchered: [true]) }
        let(:old_organization)      { Organization.create(title: ['old org'], team_id: [old_team.id]) }
        let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
        let(:old_team)              { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
        let(:old_team_manager)      { User.create(email: 'oldmanager@test.com', password: 'password') }
        let(:old_team_depositor)    { User.create(email: 'olddepositor@test.com', password: 'password') }
        let(:old_team_viewer)       { User.create(email: 'oldviewer@test.com', password: 'password') }
        let(:params)                { { id: processing_event.id, 'processing_event' => { 'work_parents_attributes' => parent_attributes } } }

        before do
          old_organization.ordered_members << old_specimen
          old_specimen.ordered_members << imaging_event

          old_team.create_collection_groups
          old_team.managers << old_team_manager
          old_team.depositors << old_team_depositor
          old_team.viewers << old_team_viewer
          old_team.user_groups.each(&:save)

          media.read_groups += old_team.user_groups.map(&:name)

          works = [old_organization, old_specimen, imaging_event, media]
          works.each(&:save)
          works.each(&:reload)
        end

        context 'and the parent imaging event is not changed' do
          let(:parent_attributes) { { '1' => { 'id' => imaging_event.id, '_destroy' => 'false' } } }

          before do
            imaging_event.ordered_members << processing_event
            processing_event.ordered_members << media
            works = [imaging_event, processing_event, media]
            works.each(&:save)
            works.each(&:reload)

            allow(subject).to receive(:new_parent_ancestors).and_return([imaging_event, old_organization, old_specimen])
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

        context 'and the parent media is not changed' do
          let(:parent_attributes) { { '1' => { 'id' => media.id, '_destroy' => 'false' } } }
          let(:child_media) { Media.create(title: ['child media']) }

          before do
            imaging_event.ordered_members << media
            media.ordered_members << processing_event
            processing_event.ordered_members << child_media
            works = [imaging_event, processing_event, media, child_media]

            child_media.read_groups += old_team.user_groups.map(&:name)

            works.each(&:save)
            works.each(&:reload)

            allow(subject).to receive(:new_parent_ancestors).and_return([imaging_event, old_specimen, old_organization, media])
          end

          it 'does not update the media permissions' do
            expect(subject).not_to receive(:update_linked_team_access)
            patch :update, params: params
            expect(subject.send(:organizations_unchanged?)).to be(true)
            expect(old_team_manager.can?(:read, media)).to be(true)
            expect(old_team_depositor.can?(:read, media)).to be(true)
            expect(old_team_viewer.can?(:read, media)).to be(true)
            # child media
            expect(old_team_manager.can?(:read, child_media)).to be(true)
            expect(old_team_depositor.can?(:read, child_media)).to be(true)
            expect(old_team_viewer.can?(:read, child_media)).to be(true)
          end
        end

        context 'and the parents are changed' do
          let(:new_imaging_event) { ImagingEvent.create(title: ['new imaging event'], device_id: [device.id], ie_modality: device.modality) }
          let(:new_specimen)     { BiologicalSpecimen.new(title: ['new specimen'], vouchered: [true]) }
          let(:new_organization) { Organization.new(title: ['new org'], team_id: []) }
          let(:new_team)         { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

          before do
            works = [new_organization, new_specimen, new_imaging_event]
            works.each(&:save)
            works.each(&:reload)
            # this will be updated by the actor
            allow(subject).to receive(:new_parent_ancestors).and_return([new_imaging_event, new_specimen, new_organization])
          end

          context 'and the imaging event is updated' do
            let(:parent_attributes) { { '0' => { 'id' => imaging_event.id, '_destroy' => 'true' }, '1' => { 'id' => new_imaging_event.id, '_destroy' => 'false' } } }

            before do
              new_organization.ordered_members << new_specimen
              new_specimen.ordered_members << new_imaging_event

              imaging_event.ordered_members << processing_event
              processing_event.ordered_members << media
              works = [imaging_event, processing_event, media]
              works.each(&:save)
              works.each(&:save)
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

            context 'and the new organization does have a linked team' do
              let(:new_team)           { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
              let(:new_team_manager)   { User.create(email: 'newmanager@test.com', password: 'password') }
              let(:new_team_depositor) { User.create(email: 'newdepositor@test.com', password: 'password') }
              let(:new_team_viewer)    { User.create(email: 'newviewer@test.com', password: 'password') }

              before do
                new_organization.ordered_members << new_specimen
                new_specimen.ordered_members << new_imaging_event

                new_organization.team_id = [new_team.id]
                new_organization.save
                new_organization.reload

                works = [new_organization, new_specimen, new_imaging_event]
                works.each(&:save)
                works.each(&:reload)

                new_team.create_collection_groups
                new_team.managers << new_team_manager
                new_team.depositors << new_team_depositor
                new_team.viewers << new_team_viewer
                new_team.user_groups.each(&:save)

                allow(subject).to receive(:new_parent_ancestors).and_return([new_imaging_event, new_specimen, new_organization])
              end
              it 'removes read access for the old organization and adds read access for the new organization' do
                patch :update, params: params
                media.reload
                # old org team is removed
                expect(old_team_manager.can?(:read, media)).to be(false)
                expect(old_team_depositor.can?(:read, media)).to be(false)
                expect(old_team_viewer.can?(:read, media)).to be(false)
                # new org team is added
                expect(new_team_manager.can?(:read, media)).to be(true)
                expect(new_team_depositor.can?(:read, media)).to be(true)
                expect(new_team_viewer.can?(:read, media)).to be(true)
              end
            end
          end
        end
        context 'and the media is updated' do
          let(:new_media)         { Media.create(title: ['new media']) }
          let(:new_imaging_event) { ImagingEvent.create(title: ['new imaging event'], device_id: [device.id], ie_modality: device.modality) }
          let(:new_organization)  { Organization.create(title: ['new organization']) }
          let(:new_specimen)      { BiologicalSpecimen.create(title: ['new specimen'], vouchered: ['false']) }
          let(:child_media)       { Media.create(title: ['child media']) }
          let(:parent_attributes) { { '0' => { 'id' => media.id, '_destroy' => 'true' }, '1' => { 'id' => new_media.id, '_destroy' => 'false' } } }

          before do
            new_organization.ordered_members << new_specimen
            new_specimen.ordered_members << new_imaging_event
            new_imaging_event.ordered_members << new_media

            imaging_event.ordered_members << media
            media.ordered_members << processing_event
            processing_event.ordered_members << child_media

            child_media.read_groups += old_team.user_groups.map(&:name)

            new_imaging_event.ordered_members << new_media

            new_media.read_groups

            works = [new_organization, new_specimen, new_imaging_event, new_media, imaging_event, media, processing_event, child_media, new_imaging_event]
            works.each(&:save)
            works.each(&:save)

            allow(subject).to receive(:new_parent_ancestors).and_return([new_imaging_event, new_organization, new_specimen, new_media])
          end
          context 'and the new organization does not have a linked team' do
            it 'does not change read access for the old parent media' do
              patch :update, params: params
              media.reload
              expect(old_team_manager.can?(:read, media)).to be(true)
              expect(old_team_depositor.can?(:read, media)).to be(true)
              expect(old_team_viewer.can?(:read, media)).to be(true)
            end
            it 'removes read access for the old organization for child media' do
              patch :update, params: params
              child_media.reload
              expect(old_team_manager.can?(:read, child_media)).to be(false)
              expect(old_team_depositor.can?(:read, child_media)).to be(false)
              expect(old_team_viewer.can?(:read, child_media)).to be(false)
            end
          end
          context 'and the new organization does have a linked team' do
            let(:new_team)           { Collection.create(title: ['New Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
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
            it 'does not change permissions for the old parent media' do
              patch :update, params: params
              media.reload
              expect(old_team_manager.can?(:read, media)).to be(true)
              expect(old_team_depositor.can?(:read, media)).to be(true)
              expect(old_team_viewer.can?(:read, media)).to be(true)
            end
            it 'removes read access for the old organization and adds read access for the new organization for the child media' do
              patch :update, params: params
              child_media.reload
              expect(old_team_manager.can?(:read, child_media)).to be(false)
              expect(old_team_depositor.can?(:read, child_media)).to be(false)
              expect(old_team_viewer.can?(:read, child_media)).to be(false)
              expect(new_team_manager.can?(:read, child_media)).to be(true)
              expect(new_team_depositor.can?(:read, child_media)).to be(true)
              expect(new_team_viewer.can?(:read, child_media)).to be(true)
            end
          end
        end
      end
    end
  end
end
