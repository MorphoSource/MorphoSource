require 'rails_helper'

RSpec.describe Morphosource::DataCuration::OrganizationNormalizationService do

  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)               { User.create(email: 'depositor@email.com', password: 'password')}
  let(:team_collection_type)    { Hyrax::CollectionType.create(title: 'Team') }
  let!(:team)                   { Collection.create(title: ['Team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let!(:project)                { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }
  let!(:organization)           { Organization.create(title: ['Organization'], team_id: [team.id]) }
  let(:specimen)                { BiologicalSpecimen.create(title: ['Biological Specimen'], organization_id: [organization.id]) }
  let(:device)                  { Device.create(title: ['Device'], modality: ['Photogrammetry']) }
  let(:imaging_event)           { ImagingEvent.create(title: ['Imaging Event'], ie_modality: device.modality, device_id: [device.id], physical_object_id: [specimen.id]) }
  let(:media1)                  { Media.create(title: ['Media1'], depositor: depositor.ms_id) }
  let(:media2)                  { Media.create(title: ['Media2'], depositor: depositor.ms_id) }
  let(:media3)                  { Media.create(title: ['Media3'], depositor: depositor.ms_id) }
  let(:media4)                  { Media.create(title: ['Media4'], depositor: depositor.ms_id) }
  let(:media5)                  { Media.create(title: ['Media5'], depositor: depositor.ms_id) }
  let(:media)                   { [media1, media2, media3, media4, media5] }
  let(:media_ids)               { [media1.id, media2.id, media3.id, media4.id, media5.id] }

  let(:params)                  { { team_id: team.id, project_id: project.id, email: user.email, update_publication_status: 'all' } }

  before do
    imaging_event.ordered_members += media
    imaging_event.save!

    media.each do |m|
      m.member_of_collections += [project]
      m.save!
    end

    Hyrax::PermissionTemplate.find_or_create_by!(source_id: team.id)
  end

  subject { described_class.call(params) }

  describe '.call' do
    it 'instantiates the service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      subject
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

    it 'returns all project media associated with the organization' do
      expect(subject.send(:media_ids)).to match_array(media_ids)
    end
  end
end
