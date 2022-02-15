# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Dashboard::LinkedTeamsController, type: :controller do
  let(:org1)                  { Organization.create(title: ['new organization'], institution_code: ['ABC']) }
  let!(:org2)                 { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }
  let!(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
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
      let(:specimen)         { BiologicalSpecimen.create(title: ['specimen'], vouchered: ["Yes"], depositor: admin.ms_id, organization_id: [org1.id]) }
      let(:device)           { Device.create(title: ['device'], modality: ['Photogrammetry']) }
      let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: admin.ms_id, device_id: [device.id], physical_object_id: [specimen.id], ie_modality: device.modality) }
      let(:media)            { Media.create(title: ['new media'], depositor: admin.ms_id) }
      let(:file_set)         { FileSet.create }
      let(:team_manager)     { User.create(email: 'manager@test.com', password: 'password') }
      let(:team_depositor)   { User.create(email: 'depositor@test.com', password: 'password') }
      let(:team_viewer)      { User.create(email: 'viewer@test.com', password: 'password') }
      let(:works)            { [imagingEvent, media, file_set] }

      before do
        allow(subject.current_user).to receive(:admin?).and_return(true)
        request.env['HTTP_REFERER'] = 'original_page'
        imagingEvent.ordered_members << media
        media.ordered_members << file_set
        team.managers << team_manager
        team.depositors << team_depositor
        team.viewers << team_viewer
        team.user_groups.each(&:save)
        works.each(&:save)
        works.each(&:reload)
      end

      context 'the team already has a linked organization' do
        let(:specimen2)        { BiologicalSpecimen.create(title: ['specimen2'], vouchered: ["Yes"], depositor: admin.ms_id, organization_id: [org2.id]) }
        let(:imagingEvent2)    { ImagingEvent.create(title: ['imagingEvent2'], depositor: admin.ms_id, device_id: [device.id], physical_object_id: [specimen2.id], ie_modality: device.modality) }
        let(:media2)           { Media.create(title: ['old media'], depositor: admin.ms_id) }
        let(:file_set2)        { FileSet.create }
        let(:works)            { [imagingEvent, imagingEvent2, media, media2, file_set2] }

        before do
          imagingEvent2.ordered_members << media2
          media2.ordered_members << file_set2
          media2.read_groups += team.user_groups.map(&:name)
          file_set2.read_groups += team.user_groups.map(&:name)
          works.each(&:save)
          works.each(&:reload)
          post :link_organization, params: params
        end

        it 'updates organization link, media and file set permissions' do
          # it clears the old organization
          expect(org2.reload.team_id).to eq([])
          # it links the new organization
          expect(org1.reload.team_id).to eq([team.id])
          # it removes the linked team's view access from the old organization's media
          expect(media2.read_groups).not_to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, media2)).to be(false)
          expect(team_depositor.can?(:read, media2)).to be(false)
          expect(team_viewer.can?(:read, media2)).to be(false)
          # it removes the linked team's view access from the old organization's file_set
          expect(file_set2.read_groups).not_to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, file_set2)).to be(false)
          expect(team_depositor.can?(:read, file_set2)).to be(false)
          expect(team_viewer.can?(:read, file_set2)).to be(false)
          # it adds view access for the linked team's members to the new organization's media
          expect(media.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, media)).to be(true)
          expect(team_depositor.can?(:read, media)).to be(true)
          expect(team_viewer.can?(:read, media)).to be(true)
          # it adds view access for the linked team's members to the new organization's file_set
          expect(file_set.reload.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
          expect(team_manager.can?(:read, file_set)).to be(true)
          expect(team_depositor.can?(:read, file_set)).to be(true)
          expect(team_viewer.can?(:read, file_set)).to be(true)
          # it redirects back to the collection dashboard page
          expect(response).to redirect_to('original_page')
        end
      end

      context 'the team does not already have a linked organization' do
        context 'the team was created as a team' do
          before do
            post :link_organization, params: params
          end
          it 'updates organization link and media permissions' do
            # it adds the new organization
            expect(org1.reload.team_id).to eq([team.id])
            # it adds view access for the linked team's members to the new organization's media
            expect(media.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
            expect(team_manager.can?(:read, media)).to be(true)
            expect(team_depositor.can?(:read, media)).to be(true)
            expect(team_viewer.can?(:read, media)).to be(true)
            # it adds view access for the linked team's members to the new organization's file_set
            expect(file_set.read_groups).to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
            expect(team_manager.can?(:read, file_set)).to be(true)
            expect(team_depositor.can?(:read, file_set)).to be(true)
            expect(team_viewer.can?(:read, file_set)).to be(true)
            # it redirects back to the collection dashboard page
            expect(response).to redirect_to('original_page')
          end
        end
        context 'the team was converted from a project' do
          let!(:project_collection_type)  { Hyrax::CollectionType.create(title: 'Project') }
          let(:project)                   { Collection.create(title: ['Project_A'], collection_type_gid: project_collection_type.gid, depositor: admin.ms_id) }
          let(:params)                    { { id: project.id, collection: { organization_id: org1.id } } }
          let(:project_manager)           { User.create(email: 'manager@test.com', password: 'password') }
          let(:project_depositor)         { User.create(email: 'depositor@test.com', password: 'password') }
          let(:project_viewer)            { User.create(email: 'viewer@test.com', password: 'password') }
          before do
            project.create_collection_groups
            project.managers << team_manager
            project.depositors << team_depositor
            project.viewers << team_viewer
            project.user_groups.each(&:save)
            project.collection_type_gid = team_collection_type.gid
            project.save!
            post :link_organization, params: params
          end
          it 'updates organization link and media permissions' do
            # it adds the new organization
            expect(org1.reload.team_id).to eq([project.id])
            # it adds view access for the linked team's members to the new organization's media
            expect(media.read_groups).to include(project.managers_group.name, project.depositors_group.name, project.viewers_group.name)
            expect(team_manager.can?(:read, media)).to be(true)
            expect(team_depositor.can?(:read, media)).to be(true)
            expect(team_viewer.can?(:read, media)).to be(true)
            # it adds view access for the linked team's members to the new organization's file set
            expect(file_set.read_groups).to include(project.managers_group.name, project.depositors_group.name, project.viewers_group.name)
            expect(team_manager.can?(:read, file_set)).to be(true)
            expect(team_depositor.can?(:read, file_set)).to be(true)
            expect(team_viewer.can?(:read, file_set)).to be(true)
            # it redirects back to the collection dashboard page
            expect(response).to redirect_to('original_page')
          end
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
    let(:rights_holder)           { ['Name: name1, Type: type1', 'Name: name2, Type: type2', 'Name: name3, Type: type3'] }
    let(:params)                  { { 
                                    id: team.id,
                                    organization:
                                      { 
                                        download_permission: download_permission.first,
                                        download_reviewer: download_reviewer.first,
                                        license: license,
                                        rights_statement: rights_statement.first,
                                        agreement_uri: agreement_uri,
                                        permits_commercial_use: permits_commercial_use.first,
                                        permits_3d_use: permits_3d_use.first,
                                        rights_holder: rights_holder 
                                      } 
                                  } }

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
      it 'updates the linked organization with the param values and redirects back' do
        org2.reload
        expect(org2.download_permission).to eq(download_permission)
        expect(org2.download_reviewer).to eq(download_reviewer)
        expect(org2.license).to eq(license)
        expect(org2.rights_statement).to eq(rights_statement)
        expect(org2.agreement_uri).to eq(agreement_uri)
        expect(org2.permits_commercial_use).to eq(permits_commercial_use)
        expect(org2.permits_3d_use).to eq(permits_3d_use)
        expect(org2.rights_holder).to match_array(rights_holder)
        # it redirects back
        expect(response).to redirect_to('original_page')
      end
    end
  end
end
