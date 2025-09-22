require 'rails_helper'

RSpec.describe Morphosource::DataCuration::OrganizationNormalizationService do

  let!(:user)                   { FactoryBot.create(:contributor) }
  let!(:depositor)              { FactoryBot.create(:contributor) }
  let!(:manager)                { FactoryBot.create(:contributor) }
  let(:team)                    { FactoryBot.create(:team, depositor: user.ms_id) }
  let(:project)                 { FactoryBot.create(:project, depositor: user.ms_id) }
  let!(:org_data_manager)       { FactoryBot.create(:contributor) }
  let(:specimen)                { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
  let(:device)                  { FactoryBot.create(:device, modality: ['Photogrammetry']) }
  let(:imaging_event)           { FactoryBot.create(:imaging_event, ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }

  let(:media1)                  { FactoryBot.create(:media, depositor: depositor.ms_id) }
  let(:media2)                  { FactoryBot.create(:media, depositor: depositor.ms_id) }
  let(:media3)                  { FactoryBot.create(:media, depositor: depositor.ms_id) }
  let(:media4)                  { FactoryBot.create(:media, depositor: depositor.ms_id) }
  let(:media5)                  { FactoryBot.create(:media, depositor: depositor.ms_id) }

  let(:project_media)           { [media1, media2, media3, media4, media5] }
  let(:project_media_ids)       { [media1.id, media2.id, media3.id, media4.id, media5.id] }

  let(:media6)                  { FactoryBot.create(:media, depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media7)                  { FactoryBot.create(:media, depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media8)                  { FactoryBot.create(:media, depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media9)                  { FactoryBot.create(:media, depositor: manager.ms_id) }
  let(:media10)                 { FactoryBot.create(:media, depositor: manager.ms_id) }

  let(:old_data_manager_media)      { [media6, media7, media8, media9, media10] }
  let(:old_data_manager_media_ids)  { [media6.id, media7.id, media8.id, media9.id, media10.id] }

  let(:media11)                 { FactoryBot.create(:media, depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media12)                 { FactoryBot.create(:media, depositor: manager.ms_id) }
  let(:media13)                 { FactoryBot.create(:media, depositor: manager.ms_id) }

  let(:project_and_old_data_manager_media)      { [media11, media12, media13] }
  let(:project_and_old_data_manager_media_ids)  { [media11.id, media12.id, media13.id] }

  let(:media)                   { project_media + old_data_manager_media + project_and_old_data_manager_media }

  subject { described_class.call(**params) }

  describe '.call' do
    let!(:organization) { FactoryBot.create(:organization, team_id: [team.id], data_manager: [org_data_manager.ms_id]) }
    let(:params)        { { team_id: team.id, project_id: project.id, old_manager_email: '', remove_previous_reviewers: 'false', email: user.email, update_publication_status: 'all' } }

    before do
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
    end

    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
    end

    context 'new data manager email is entered with incorrect capitalization' do
      before do
        params[:email] = user.email.upcase
      end
      it 'successfully finds the user' do
        expect_any_instance_of(described_class).to receive(:call)
        subject
      end
    end

    context 'new data manager email is entered incorrectly' do
      let(:email) { 'nobody@email.com' }
      before do
        params[:email] = email
      end
      it 'raises an error' do
        expect { subject }.to raise_error("One or more required parameters is not present or incorrect")
      end
    end
  end

  describe '#call' do
    let!(:organization) { FactoryBot.create(:organization, team_id: [team.id], data_manager: [org_data_manager.ms_id]) }
    let(:params)        { { team_id: team.id, project_id: project.id, old_manager_email: '', remove_previous_reviewers: 'false', email: user.email, update_publication_status: 'all' } }

    before do
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
    end

    it 'calls the media update methods' do
      expect_any_instance_of(described_class).to receive(:update_media)
      subject
    end
  end

  context 'organization is a work' do
    let!(:organization) { FactoryBot.create(:organization, team_id: [team.id], data_manager: [org_data_manager.ms_id]) }
    let(:params)        { { team_id: team.id, project_id: project.id, old_manager_email: '', remove_previous_reviewers: 'false', email: user.email, update_publication_status: 'all' } }

    before do
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
      set_up_media_relationships
    end

    describe 'get_media_ids' do
      subject { described_class.new(**params) }

      context 'only the old manager is filled out' do
        let(:params)  { { team_id: team.id, project_id: nil, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

        it "returns all of the old data manager's media associated with the organization" do
          expect(subject.send(:media_ids)).to match_array(old_data_manager_media_ids + project_and_old_data_manager_media_ids)
          expect(subject.send(:media_ids)).not_to include(*project_media_ids)
        end

        context 'media have organization_transfer_on_publish set to true' do
          before do
            (old_data_manager_media + project_and_old_data_manager_media).each do |m|
              m.organization_transfer_on_publish = true
              m.save!
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end

        context 'media have proxy deposit requests' do
          before do
            Role.create(name: 'contributor')
            org_data_manager.make_contributor
            (old_data_manager_media + project_and_old_data_manager_media).each do |m|
              ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: org_data_manager.id, sending_user_id: depositor.id)
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end
      end

      context 'only the collection id is filled out' do
        context 'collection is another project' do

          it 'returns all project media associated with the organization' do
            expect(subject.send(:media_ids)).to match_array(project_media_ids + project_and_old_data_manager_media_ids)
            expect(subject.send(:media_ids)).not_to include(*old_data_manager_media_ids)
          end

          context 'media have organization_transfer_on_publish set to true' do
            before do
              (project_media + project_and_old_data_manager_media).each do |m|
                m.organization_transfer_on_publish = true
                m.save!
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end

          context 'media have proxy deposit requests' do
            before do
              Role.create(name: 'contributor')
              org_data_manager.make_contributor
              (project_media + project_and_old_data_manager_media).each do |m|
                ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: org_data_manager.id, sending_user_id: depositor.id)
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end
        end

        context 'collection is the team' do
          let(:params)  { { team_id: team.id, project_id: team.id, old_manager_email: nil, email: user.email, update_publication_status: 'all' } }

          before do
            project_media.each do |m|
              m.member_of_collections += [team]
              m.save!
            end

            project_and_old_data_manager_media.each do |m|
              m.member_of_collections += [team]
              m.save!
            end
          end

          it 'returns all media associated with the organization belonging to the team' do
            expect(subject.send(:media_ids)).to match_array(project_media_ids + project_and_old_data_manager_media_ids)
          end

          context 'media have organization_transfer_on_publish set to true' do
            before do
              (project_media + project_and_old_data_manager_media).each do |m|
                m.organization_transfer_on_publish = true
                m.save!
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end

          context 'media have proxy deposit requests' do
            before do
              Role.create(name: 'contributor')
              org_data_manager.make_contributor
              (project_media + project_and_old_data_manager_media).each do |m|
                ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: org_data_manager.id, sending_user_id: depositor.id)
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end
        end

        context 'both collection id and old manager are filled out' do
          let(:params)  { { team_id: team.id, project_id: project.id, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

          it "returns all of the old data manager's media that is both in the collection and associated with the organization" do
            expect(subject.send(:media_ids)).to match_array(project_and_old_data_manager_media_ids)
            expect(subject.send(:media_ids)).not_to include(*project_media_ids)
            expect(subject.send(:media_ids)).not_to include(*old_data_manager_media_ids)
          end

          context 'media have organization_transfer_on_publish set to true' do
            before do
              project_and_old_data_manager_media.each do |m|
                m.organization_transfer_on_publish = true
                m.save!
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end

          context 'media have proxy deposit requests' do
            before do
              Role.create(name: 'contributor')
              org_data_manager.make_contributor
              project_and_old_data_manager_media.each do |m|
                ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: org_data_manager.id, sending_user_id: depositor.id)
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end
        end


      end
    end
  end

  context 'organization is a collection' do
    let!(:organization)  { FactoryBot.create(:organization_collection) }

    let(:params)  { { team_id: organization.id, project_id: project.id, old_manager_email: '', remove_previous_reviewers: 'false', email: user.email, update_publication_status: 'all' } }

    before do
      Hyrax::PermissionTemplate.find_or_create_by!(source_id: organization.id)
      allow(Collection).to receive(:find).and_call_original
      allow(Collection).to receive(:find).with(organization.id).and_return(organization)
      set_up_media_relationships
    end

    describe 'get_media_ids' do
      subject { described_class.new(**params) }

      context 'only the old manager is filled out' do
        let(:params)  { { team_id: organization.id, project_id: nil, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

        it "returns all of the old data manager's media associated with the organization" do
          expect(subject.send(:media_ids)).to match_array(old_data_manager_media_ids + project_and_old_data_manager_media_ids)
          expect(subject.send(:media_ids)).not_to include(*project_media_ids)
        end

        context 'media have organization_transfer_on_publish set to true' do
          before do
            (old_data_manager_media + project_and_old_data_manager_media).each do |m|
              m.organization_transfer_on_publish = true
              m.save!
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end

        context 'media have proxy deposit requests' do
          before do
            (old_data_manager_media + project_and_old_data_manager_media).each do |m|
              ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: organization.id, sending_user_id: depositor.id)
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end
      end

      context 'only the collection id is filled out' do
        context 'collection is another project' do

          it 'returns all project media associated with the organization' do
            expect(subject.send(:media_ids)).to match_array(project_media_ids + project_and_old_data_manager_media_ids)
            expect(subject.send(:media_ids)).not_to include(*old_data_manager_media_ids)
          end

          context 'media have organization_transfer_on_publish set to true' do
            before do
              (project_media + project_and_old_data_manager_media).each do |m|
                m.organization_transfer_on_publish = true
                m.save!
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end

          context 'media have proxy deposit requests' do
            before do
              (project_media + project_and_old_data_manager_media).each do |m|
                ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: organization.id, sending_user_id: depositor.id)
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end
        end

        context 'collection is the organization' do
          let(:params)  { { team_id: organization.id, project_id: organization.id, old_manager_email: nil, email: user.email, update_publication_status: 'all' } }

          before do
            project_media.each do |m|
              m.owner = organization.id
              m.save!
            end

            project_and_old_data_manager_media.each do |m|
              m.owner = organization.id
              m.save!
            end
          end

          it 'returns all media associated with the organization managed by the organization' do
            expect(subject.send(:media_ids)).to match_array(project_media_ids + project_and_old_data_manager_media_ids)
          end

          context 'media have organization_transfer_on_publish set to true' do
            before do
              (project_media + project_and_old_data_manager_media).each do |m|
                m.organization_transfer_on_publish = true
                m.save!
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end

          context 'media have proxy deposit requests' do
            before do
              Role.create(name: 'contributor')
              org_data_manager.make_contributor
              (project_media + project_and_old_data_manager_media).each do |m|
                ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: organization.id, sending_user_id: depositor.id)
              end
            end
            it 'does not return the media' do
              expect(subject.send(:media_ids)).to match_array([])
            end
          end
        end
      end

      context 'both collection id and old manager are filled out' do
        let(:params)  { { team_id: organization.id, project_id: project.id, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

        it "returns all of the old data manager's media that is both in the collection and associated with the organization" do
          expect(subject.send(:media_ids)).to match_array(project_and_old_data_manager_media_ids)
          expect(subject.send(:media_ids)).not_to include(*project_media_ids)
          expect(subject.send(:media_ids)).not_to include(*old_data_manager_media_ids)
        end

        context 'media have organization_transfer_on_publish set to true' do
          before do
            project_and_old_data_manager_media.each do |m|
              m.organization_transfer_on_publish = true
              m.save!
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end

        context 'media have proxy deposit requests' do
          before do
            Role.create(name: 'contributor')
            org_data_manager.make_contributor
            project_and_old_data_manager_media.each do |m|
              ProxyDepositRequest.create(work_id: m.id, organization_transfer: true, receiving_user_id: organization.id, sending_user_id: depositor.id)
            end
          end
          it 'does not return the media' do
            expect(subject.send(:media_ids)).to match_array([])
          end
        end
      end
    end
  end

  def set_up_media_relationships
    imaging_event.ordered_members += media
    imaging_event.save!

    project_media.each do |m|
      m.member_of_collections += [project]
      m.save!
    end

    project_and_old_data_manager_media.each do |m|
      m.member_of_collections += [project]
      m.save!
    end

    old_data_manager_media.each(&:update_index)
  end
end
