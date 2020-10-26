# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work BiologicalSpecimen`
require 'rails_helper'

RSpec.describe Hyrax::BiologicalSpecimensController do
  it 'has curation_concern_type ::BiologicalSpecimen' do
    expect(described_class.curation_concern_type).to be(::BiologicalSpecimen)
  end

  it 'has show_presenter Hyrax::BiologicalSpecimenPresenter' do
    expect(described_class.show_presenter).to be(Hyrax::BiologicalSpecimenPresenter)
  end

  describe '#showcase' do
    context 'user is not signed in' do
      context 'work is public' do
        let(:public_specimen) { BiologicalSpecimen.create(title: ['public specimen'], visibility: 'open', vouchered: ['Yes']) }
        it 'is authorized' do
          get :showcase, params: { id: public_specimen.id }
          expect(response.status).to eq(200)
        end
      end
      context 'work is private' do
        let(:private_specimen) { BiologicalSpecimen.create(title: ['private specimen'], visibility: 'restricted', vouchered: ['Yes']) }
        it 'is redirects to sign in' do
          get :showcase, params: { id: private_specimen.id }
          expect(response.status).to eq(302)
        end
      end
    end
  end

  describe 'instance methods' do
    let(:actor)     { double(update: true) }
    let(:specimen)  { BiologicalSpecimen.create(title: ['specimen'], vouchered: [true]) }
    let(:user)      { User.create(email: 'email@email.com', password: 'password', ms_id: 'user') }

    before do
      allow(subject).to receive(:actor).and_return(actor)
      allow(subject).to receive(:authorize!).with(:update, specimen).and_return(true)
      sign_in user
    end

    describe '#update' do
      context 'when it successfully updates' do
        it 'calls #update_media_team_access' do
          expect(subject).to receive(:update_media_team_access)
          patch :update, params: { id: specimen.id }
        end
      end
    end

    describe '#update_media_team_access' do
      context "when the specimen's params don't include parents" do
        it 'returns nil for parents_attributes' do
          expect(subject).to receive(:parents_attributes).and_return(nil)
          patch :update, params: { id: specimen.id }
        end
      end

      context "when the specimen's params include parents" do
        let(:media)                 { Media.create(title: ['media']) }
        let(:media2)                { Media.create(title: ['media2']) }
        let(:imaging_event)         { ImagingEvent.create(title: ['imaging event']) }
        let(:processing_event)      { ProcessingEvent.create(title: ['processing event']) }
        let(:old_organization)      { Organization.create(title: ['old org'], team_id: [old_team.id]) }
        let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
        let(:old_team)              { Collection.create(title: ['Old Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
        let(:old_team_manager)      { User.create(email: 'oldmanager@test.com', password: 'password') }
        let(:old_team_depositor)    { User.create(email: 'olddepositor@test.com', password: 'password') }
        let(:old_team_viewer)       { User.create(email: 'oldviewer@test.com', password: 'password') }
        let(:params)                { { id: specimen.id, 'biological_specimen' => { 'work_parents_attributes' => parent_attributes } } }

        before do
          old_organization.ordered_members << specimen
          specimen.ordered_members << imaging_event
          imaging_event.ordered_members << media
          media.ordered_members << processing_event
          processing_event.ordered_members << media2

          old_team.create_collection_groups
          old_team.managers << old_team_manager
          old_team.depositors << old_team_depositor
          old_team.viewers << old_team_viewer
          old_team.user_groups.each(&:save)

          media.read_groups += old_team.user_groups.map(&:name)
          media2.read_groups += old_team.user_groups.map(&:name)

          works = [old_organization, specimen, imaging_event, media, media2]
          works.each(&:save)
          works.each(&:reload)
        end

        context 'and the parent organization is not changed' do
          let(:parent_attributes) { { '1' => { 'id' => old_organization.id, '_destroy' => 'false' } } }

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
          let(:new_organization) { Organization.new(title: ['new org'], team_id: []) }
          let(:parent_attributes) { { '0' => { 'id' => old_organization.id, '_destroy' => 'true' }, '1' => { 'id' => new_organization.id, '_destroy' => 'false' } } }

          before do
            # this will be updated by the actor
            allow(subject).to receive(:new_orgs).and_return([new_organization])
          end

          context 'and the new organization does not have a linked team' do
            it 'removes read access for the old organization' do
              patch :update, params: params
              [media, media2].each(&:reload)
              # media
              expect(old_team_manager.can?(:read, media)).to be(false)
              expect(old_team_depositor.can?(:read, media)).to be(false)
              expect(old_team_viewer.can?(:read, media)).to be(false)
              # media2
              expect(old_team_manager.can?(:read, media2)).to be(false)
              expect(old_team_depositor.can?(:read, media2)).to be(false)
              expect(old_team_viewer.can?(:read, media2)).to be(false)
            end
          end

          context 'and the new organization has a linked team' do
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

            it 'removes read access for the old team, and adds read access for the new team' do
              patch :update, params: params
              [media, media2].each(&:reload)
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
            end
          end
        end
      end
    end
  end
end
