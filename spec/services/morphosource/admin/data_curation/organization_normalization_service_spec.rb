require 'rails_helper'

RSpec.describe Morphosource::DataCuration::OrganizationNormalizationService do

  let!(:user)                   { User.create(email: 'user@email.com', password: 'password') }
  let!(:depositor)              { User.create(email: 'depositor@email.com', password: 'password') }
  let!(:manager)                { User.create(email: 'manager@email.com', password: 'password') }
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let!(:team)                   { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let!(:project)                { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let!(:org_data_manager)       { User.create(email: 'data_manager@email.com', password: 'password') }
  let!(:organization)           { Organization.create(title: ['Organization'], team_id: [team.id], data_manager: [org_data_manager.ms_id]) }
  let(:specimen)                { BiologicalSpecimen.create(title: ['Biological Specimen'], organization_id: [organization.id]) }
  let(:device)                  { Device.create(title: ['Device'], modality: ['Photogrammetry']) }
  let(:imaging_event)           { ImagingEvent.create(title: ['Imaging Event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }

  let(:media1)                  { Media.create(title: ['Media1'], depositor: depositor.ms_id) }
  let(:media2)                  { Media.create(title: ['Media2'], depositor: depositor.ms_id) }
  let(:media3)                  { Media.create(title: ['Media3'], depositor: depositor.ms_id) }
  let(:media4)                  { Media.create(title: ['Media4'], depositor: depositor.ms_id) }
  let(:media5)                  { Media.create(title: ['Media5'], depositor: depositor.ms_id) }

  let(:project_media)           { [media1, media2, media3, media4, media5] }
  let(:project_media_ids)       { [media1.id, media2.id, media3.id, media4.id, media5.id] }

  let(:media6)                  { Media.create(title: ['Media6'], depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media7)                  { Media.create(title: ['Media7'], depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media8)                  { Media.create(title: ['Media8'], depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media9)                  { Media.create(title: ['Media9'], depositor: manager.ms_id) }
  let(:media10)                 { Media.create(title: ['Media10'], depositor: manager.ms_id) }

  let(:old_data_manager_media)      { [media6, media7, media8, media9, media10] }
  let(:old_data_manager_media_ids)  { [media6.id, media7.id, media8.id, media9.id, media10.id] }

  let(:media11)                 { Media.create(title: ['Media11'], depositor: depositor.ms_id, owner: manager.ms_id) }
  let(:media12)                 { Media.create(title: ['Media12'], depositor: manager.ms_id) }
  let(:media13)                 { Media.create(title: ['Media13'], depositor: manager.ms_id) }

  let(:project_and_old_data_manager_media)      { [media11, media12, media13] }
  let(:project_and_old_data_manager_media_ids)  { [media11.id, media12.id, media13.id] }

  let(:media)                   { project_media + old_data_manager_media + project_and_old_data_manager_media }

  let(:params)                  { { team_id: team.id, collection_id: project.id, old_manager_email: '', remove_previous_reviewers: 'false', email: user.email, update_publication_status: 'all' } }

  before do
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

    Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
  end

  subject { described_class.call(params) }

  describe '.call' do
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
    it 'calls the media update methods' do
      expect_any_instance_of(described_class).to receive(:update_media)
      subject
    end
  end

  describe 'get_media_ids' do
    subject { described_class.new(params) }

    context 'only the old manager is filled out' do
      let(:params)  { { team_id: team.id, collection_id: nil, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

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
        let(:params)  { { team_id: team.id, collection_id: team.id, old_manager_email: nil, email: user.email, update_publication_status: 'all' } }

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
        let(:params)  { { team_id: team.id, collection_id: project.id, old_manager_email: manager.email, email: user.email, update_publication_status: 'all' } }

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
