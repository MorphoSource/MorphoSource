# frozen_string_literal: true

require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Morphosource::Dashboard::LinkedTeamsController, type: :controller do
  let(:org1)                  { Organization.create(title: ['new organization'], institution_code: ['ABC']) }
  let!(:org2)                 { Organization.create(title: ['old organization'], institution_code: ['DEF'], team_id: [team.id]) }
  let(:admin)                 { User.create(email: 'email@email.com', password: 'password') }
  let(:team)                  { Collection.create(title: ['Team_A'], collection_type_gid: team_collection_type.to_global_id, depositor: admin.ms_id) }
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
      let(:device)           { FactoryBot.valkyrie_create(:device_resource, title: ['device'], modality: ['Photogrammetry']) }
      let(:imagingEvent)     { ImagingEvent.create(title: ['imagingEvent'], depositor: admin.ms_id, device_id: [device.id.to_s], physical_object_id: [specimen.id], ie_modality: device.modality) }
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

      context 'the team does not already have a linked organization' do
        context 'the team was created as a team' do
          it 'updates organization link and media permissions' do
            post :link_organization, params: params
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
          context "the team has read access to another organization's media" do
            let!(:rogue_media) { Media.create(title: ['rogue media']) }
            before do
              rogue_media.read_groups += [team.managers_group.name]
              rogue_media.save!
            end
            it 'redirects with an error and does not update the organization and media' do
              post :link_organization, params: params
              # it does not add the new organization
              expect(org1.reload.team_id).not_to eq([team.id])
              # it does not add view access for the linked team's members to the new organization's media
              expect(media.read_groups).not_to include(team.managers_group.name, team.depositors_group.name, team.viewers_group.name)
              expect(team_manager.can?(:read, media)).to be(false)
              expect(team_depositor.can?(:read, media)).to be(false)
              expect(team_viewer.can?(:read, media)).to be(false)
              # it redirects back to the collection dashboard page with an error
              expect(response.flash[:error]).to include(rogue_media.id)
              expect(response).to redirect_to('original_page')
            end
          end
          context "the team has read access to the linked organization's media" do
            let!(:rogue_media) { Media.create(title: ['rogue media']) }
            before do
              rogue_media.read_groups += [team.managers_group.name]
              imagingEvent.ordered_members << rogue_media
              imagingEvent.save!
              rogue_media.save!
            end
            it 'updates organization link and media permissions' do
              post :link_organization, params: params
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
          context "the team has edit access to the linked organization's media" do
            let!(:rogue_media) { Media.create(title: ['rogue media']) }
            before do
              rogue_media.edit_groups += [team.managers_group.name]
              imagingEvent.ordered_members << rogue_media
              imagingEvent.save!
              rogue_media.save!
            end
            it 'updates organization link and media permissions' do
              post :link_organization, params: params
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
        end
        context 'the team was converted from a project' do
          let(:project)                   { Collection.create(title: ['Project_A'], collection_type_gid: project_collection_type.to_global_id, depositor: admin.ms_id) }
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
            project.collection_type_gid = team_collection_type.to_global_id
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

  describe '#update_permissions on an OrganizationCollection' do
    let(:reviewer)      { FactoryBot.create(:contributor) }
    let(:reviewer2)     { FactoryBot.create(:contributor) }
    let(:organization)  { FactoryBot.create(:organization_collection, depositor: admin.ms_id) }

    def sign_in_as_site_admin
      site_admin = FactoryBot.create(:admin)
      allow(subject).to receive(:current_user).and_return(site_admin)
      allow(site_admin).to receive(:can?).with(:edit, organization).and_return(true)
    end

    def patch_permissions(organization_params)
      patch :update_permissions, params: { id: organization.id, organization: organization_params }
      organization.reload
    end

    before do
      request.env['HTTP_REFERER'] = 'original_page'
      allow(subject).to receive(:current_user).and_return(admin)
      allow(admin).to receive(:can?).with(:edit, organization).and_return(true)
    end

    it 'round-trips the two new Manager-editable fields' do
      patch_permissions(
        managers_are_download_reviewers: 'false',
        custom_download_reviewer_users: [reviewer.ms_id, reviewer2.ms_id]
      )

      expect(organization.managers_are_download_reviewers).to be(false)
      expect(organization.custom_download_reviewer_users).to match_array([reviewer.ms_id, reviewer2.ms_id])
    end

    it 'casts the posted string "false" to boolean false' do
      patch_permissions(
        managers_are_download_reviewers: 'false',
        custom_download_reviewer_users: [reviewer.ms_id]
      )

      expect(organization.managers_are_download_reviewers).to be(false)
      expect(organization.download_reviewers).to eq([reviewer.ms_id])
    end

    it 'casts the posted string "true" to boolean true' do
      patch_permissions(managers_are_download_reviewers: 'true')

      expect(organization.managers_are_download_reviewers).to be(true)
    end

    it 'never assigns an Array to either scalar boolean' do
      sign_in_as_site_admin

      expect { patch_permissions(reviews_object_media_downloads: 'true') }.not_to raise_error

      expect(organization.reviews_object_media_downloads).to be(true)
    end

    describe 'administrator-controlled fields' do
      let(:manager) { FactoryBot.create(:contributor) }

      it 'drops them when the user is not an admin' do
        allow(subject).to receive(:current_user).and_return(manager)
        allow(manager).to receive(:can?).with(:edit, organization).and_return(true)

        patch_permissions(reviews_object_media_downloads: 'true', media_ownership_transfer: 'true')

        expect(organization.reviews_object_media_downloads).to be_nil
        expect(organization.media_ownership_transfer).to be_falsey
      end

      it 'accepts them from an admin' do
        sign_in_as_site_admin

        patch_permissions(reviews_object_media_downloads: 'true')

        expect(organization.reviews_object_media_downloads).to be(true)
      end
    end

    describe 'a rejected save' do
      before { allow_any_instance_of(OrganizationCollection).to receive(:update).and_return(false) }

      it 'reports the failure instead of claiming success' do
        patch_permissions(city: 'Durham')

        expect(flash[:error]).to be_present
        expect(flash[:notice]).to be_blank
      end

    end

    describe 'the organization transfer job' do
      let(:new_manager)     { FactoryBot.create(:contributor) }
      let(:pending_request) { instance_double(ProxyDepositRequest) }

      before do
        allow(subject).to receive(:pending_transfer_requests)
          .and_return([[pending_request], new_manager])
      end

      it 'enqueues after a successful save' do
        expect(UpdateOrganizationTransferRequestsJob)
          .to receive(:perform_later).with([pending_request], new_manager)

        patch_permissions(city: 'Durham')
      end

      it 'enqueues nothing when the save is rejected' do
        allow_any_instance_of(OrganizationCollection).to receive(:update).and_return(false)
        expect(UpdateOrganizationTransferRequestsJob).not_to receive(:perform_later)

        patch_permissions(city: 'Durham')
      end
    end

    it 'still reports success when the save succeeds' do
      patch_permissions(city: 'Durham')

      expect(flash[:notice]).to eq('Permissions updated.')
      expect(flash[:error]).to be_blank
    end

    it 'no longer accepts download_reviewer' do
      expect(subject.send(:multi_value_fields)).not_to include(:download_reviewer)
      expect(subject.send(:multi_value_fields)).to include(:custom_download_reviewer_users)
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
