# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Dashboard::LinkedTeamsController, type: :controller do
  let(:org1)                  { Organization.create(title: ['new organization'], institution_code: ['ABC']) }
  let(:org2)                  { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }
  let(:team_collection_type)  { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:admin)                 { User.create(email: 'email@email.com', password: 'password') }
  let(:team)                  { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.gid, depositor: admin.ms_id) }
  let(:params)                { { id: team.id, collection: { organization_id: org1.id } } }

  before do
    team.create_collection_groups
    sign_in admin
  end

  describe '#link_organization' do
    context 'the current user is not an admin' do
      it 'should not call #clear_organization or #add_organization' do
        expect(subject).to_not receive(:clear_organization)
        expect(subject).to_not receive(:add_organization)
        post :link_organization, params: params
      end
    end

    context 'the current user is an admin' do
      let(:specimen)         { BiologicalSpecimen.create(title: ['specimen'], vouchered: [true], depositor: admin.ms_id) }
      let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: admin.ms_id) }
      let(:media)            { Media.create(title: ['new media'], depositor: admin.ms_id) }
      let(:team_manager)     { User.create(email: 'manager@test.com', password: 'password') }
      let(:team_depositor)   { User.create(email: 'depositor@test.com', password: 'password') }
      let(:team_viewer)      { User.create(email: 'viewer@test.com', password: 'password') }
      let(:works)             { [org1, specimen, imagingEvent, media] }

      before do
        allow(subject.current_user).to receive(:admin?).and_return(true)
        request.env['HTTP_REFERER'] = 'original_page'

        org1.ordered_members << specimen
        specimen.ordered_members << imagingEvent
        imagingEvent.ordered_members << media

        team.managers << team_manager
        team.depositors << team_depositor
        team.viewers << team_viewer
        team.user_groups.each(&:save)

        works.each(&:save)
        works.each(&:reload)
      end

      context 'the team already has a linked organization' do
        let(:specimen2)        { BiologicalSpecimen.create(title: ['specimen2'], vouchered: [true], depositor: admin.ms_id) }
        let(:imagingEvent2)    { ImagingEvent.create(title: ['imagingEvent2'], depositor: admin.ms_id) }
        let(:media2)           { Media.create(title: ['old media'], depositor: admin.ms_id) }
        let(:works)             { [org1, org2, specimen, specimen2, imagingEvent, imagingEvent2, media, media2] }

        before do
          org2.ordered_members << specimen2
          specimen2.ordered_members << imagingEvent2
          imagingEvent2.ordered_members << media2

          media2.read_groups += team.user_groups.map(&:name)

          works.each(&:save)
          works.each(&:reload)

          post :link_organization, params: params
        end

        it 'clears the old organization' do
          expect(org2.reload.team_id).to eq([])
        end
        it 'adds the new organization' do
          expect(org1.reload.team_id).to eq([team.id])
        end
        it "removes the linked team's view access from the old organization's media" do
          expect(media2.read_groups).not_to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, media2)).to be(false)
          expect(team_depositor.can?(:read, media2)).to be(false)
          expect(team_viewer.can?(:read, media2)).to be(false)
        end
        it "adds view access for the linked team's members to the new organization's media" do
          expect(media.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, media)).to be(true)
          expect(team_depositor.can?(:read, media)).to be(true)
          expect(team_viewer.can?(:read, media)).to be(true)
        end
        it 'redirects back to the collection dashboard page' do
          expect(response).to redirect_to('original_page')
        end
      end

      context 'the team does not already have a linked organization' do
        before do
          post :link_organization, params: params
        end
        it 'adds the new organization' do
          expect(org1.reload.team_id).to eq([team.id])
        end
        it "adds view access for the linked team's members to the new organization's media" do
          expect(media.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, media)).to be(true)
          expect(team_depositor.can?(:read, media)).to be(true)
          expect(team_viewer.can?(:read, media)).to be(true)
        end
        it 'redirects back to the collection dashboard page' do
          expect(response).to redirect_to('original_page')
        end
      end
    end
  end
end
