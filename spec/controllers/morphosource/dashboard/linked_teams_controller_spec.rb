# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Dashboard::LinkedTeamsController, type: :controller do
  let(:org1)                  { Organization.create(title: ['new organization'], institution_code: ['ABC']) }
  let!(:org2)                  { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }
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
      let(:device)           { Device.create(title: ['device'], modality: ['Photogrammetry']) }
      let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: admin.ms_id, device_id: [device.id], ie_modality: device.modality) }
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
        let(:imagingEvent2)    { ImagingEvent.create(title: ['imagingEvent2'], depositor: admin.ms_id, device_id: [device.id], ie_modality: device.modality) }
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

  describe '#update_permissions' do
    let(:download_permission)     { ['download_permission'] }
    let(:download_reviewer)       { [admin.ms_id] }
    let(:license)                 { ['license'] }
    let(:rights_statement)        { ['rights statement'] }
    let(:agreement_uri)           { ['agreement uri'] }
    let(:permits_commercial_use)  { ['true'] }
    let(:permits_3d_use)          { ['true'] }
    let(:rights_holder_name)      { ['name1', 'name2', 'name3'] }
    let(:rights_holder_type)      { ['type1', 'type2', 'type3'] }
    let(:rights_holder)           { ['Name: name1, Type: type1', 'Name: name2, Type: type2', 'Name: name3, Type: type3'] }
    let(:funding)                 { ['funding'] }
    let(:publisher)               { ['publisher'] }
    let(:cite_as)                 { ['cite as'] }
    let(:params)                  { { organization:
                                      { download_permission: download_permission.first,
                                        download_reviewer: download_reviewer.first,
                                        license: license,
                                        rights_statement: rights_statement.first,
                                        agreement_uri: agreement_uri,
                                        permits_commercial_use: permits_commercial_use.first,
                                        permits_3d_use: permits_3d_use.first,
                                        rights_holder_name: rights_holder_name,
                                        rights_holder_type: rights_holder_type,
                                        funding: funding,
                                        publisher: publisher,
                                        cite_as: cite_as.first },
                                        id: team.id } }

    context 'user is not a team admin' do
      before do
        allow(admin).to receive(:can?).with(:edit, team).and_return(false)
        patch :update_permissions, params: params
      end
      it 'returns' do
        expect(subject).to_not receive(:update_organization)
        expect(subject).to_not receive(:redirect_back_organization)
      end
    end
    context 'user is a team admin' do
      before do
        request.env['HTTP_REFERER'] = 'original_page'
        allow(subject).to receive(:current_user).and_return(admin)
        allow(admin).to receive(:can?).with(:edit, team).and_return(true)
        patch :update_permissions, params: params
      end
      it 'updates the linked organization with the param values' do
        org2.reload
        expect(org2.download_permission).to eq(download_permission)
        expect(org2.download_reviewer).to eq(download_reviewer)
        expect(org2.license).to eq(license)
        expect(org2.rights_statement).to eq(rights_statement)
        expect(org2.agreement_uri).to eq(agreement_uri)
        expect(org2.permits_commercial_use).to eq(permits_commercial_use)
        expect(org2.permits_3d_use).to eq(permits_3d_use)
        expect(org2.rights_holder).to match_array(rights_holder)
        expect(org2.funding).to eq(funding)
        expect(org2.publisher).to eq(publisher)
        expect(org2.cite_as).to eq(cite_as)
      end
      it 'redirects back' do
        expect(response).to redirect_to('original_page')
      end
    end
  end
end
