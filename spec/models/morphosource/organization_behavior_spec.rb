# frozen_string_literal= true
require 'rails_helper'
RSpec.describe Organization, type: :model do
  let(:another_org)   { FactoryBot.create(:organization) }
  let(:organization)  { FactoryBot.create(:organization) }

  # returns media and objects associated with the organization through the organization's devices
  describe 'device_cultural_heritage_objects, device_media, device_physical_objects, device_specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [another_org.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [another_org.id]) }
    let(:deviceA)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id.to_s], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id.to_s], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:update_index)
    end

    it 'returns the correct records' do
      # device_cultural_heritage_objects
      expect(organization.device_cultural_heritage_objects).to eq([cho])
      # device_media
      expect(organization.device_media).to eq([mediaA, mediaB])
      # device_physical_objects
      expect(organization.device_physical_objects).to match_array([specimen, cho])
      # device_specimens
      expect(organization.device_specimens).to eq([specimen])
    end
  end

  # returns media and objects associated with the organization
  describe 'cultural_heritage_objects, media, physical_objects, specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:deviceA)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id.to_s], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id.to_s], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:update_index)
    end

    it 'returns the correct records' do
      # cultural_heritage_objects
      expect(organization.cultural_heritage_objects).to eq([cho])
      # media
      expect(organization.media).to match_array([mediaA, mediaB])
      # physical_objects
      expect(organization.physical_objects).to match_array([specimen, cho])
      # specimens
      expect(organization.specimens).to eq([specimen])
    end
  end
end

RSpec.describe OrganizationCollection, type: :model do
  let(:another_org)   { FactoryBot.create(:organization_collection) }
  let(:organization)  { FactoryBot.create(:organization_collection) }

  # returns media and objects associated with the organization through the organization's devices
  describe 'device_cultural_heritage_objects, device_media, device_physical_objects, device_specimens' do
    let(:specimen)        { FactoryBot.create(:biological_specimen, organization_id: [another_org.id]) }
    let(:cho)             { FactoryBot.create(:cultural_heritage_object, organization_id: [another_org.id]) }
    let(:deviceA)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:deviceB)         { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:imaging_eventA)  { FactoryBot.create(:imaging_event, device_id: [deviceA.id.to_s], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)  { FactoryBot.create(:imaging_event, device_id: [deviceB.id.to_s], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)          { FactoryBot.create(:media) }
    let(:mediaB)          { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:update_index)
    end

    it 'returns the correct records' do
      # device_cultural_heritage_objects
      expect(organization.device_cultural_heritage_objects).to eq([cho])
      # device_media
      expect(organization.device_media).to eq([mediaA, mediaB])
      # device_physical_objects
      expect(organization.device_physical_objects).to match_array([specimen, cho])
      # device_specimens
      expect(organization.device_specimens).to eq([specimen])
    end
  end

  # returns media and objects associated with the organization
  describe 'cultural_heritage_objects, media, physical_objects, specimens' do
    let(:specimen)                  { FactoryBot.create(:biological_specimen, organization_id: [organization.id]) }
    let(:cho)  { FactoryBot.create(:cultural_heritage_object, organization_id: [organization.id]) }
    let(:deviceA)                   { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:deviceB)                   { FactoryBot.create(:device_resource, organization_id: [organization.id]) }
    let(:imaging_eventA)            { FactoryBot.create(:imaging_event, device_id: [deviceA.id.to_s], ie_modality: deviceA.modality, physical_object_id: [cho.id]) }
    let(:imaging_eventB)            { FactoryBot.create(:imaging_event, device_id: [deviceB.id.to_s], ie_modality: deviceB.modality, physical_object_id: [specimen.id]) }
    let(:mediaA)                    { FactoryBot.create(:media) }
    let(:mediaB)                    { FactoryBot.create(:media) }

    before do
      imaging_eventA.ordered_members << mediaA
      imaging_eventB.ordered_members << mediaB
      [imaging_eventA, imaging_eventB].each(&:save!)
      [mediaA, mediaB].each(&:update_index)
    end

    it 'returns the correct records' do
      # cultural_heritage_objects
      expect(organization.cultural_heritage_objects).to eq([cho])
      # media
      expect(organization.media).to match_array([mediaA, mediaB])
      # physical_objects
      expect(organization.physical_objects).to match_array([specimen, cho])
      # specimens
      expect(organization.specimens).to eq([specimen])
    end
  end

  describe '#media_download_reviewers' do
    let(:user)  { FactoryBot.create(:registered_user) }
    let(:user2) { FactoryBot.create(:registered_user) }

    context 'the organization has a download_reviewer set' do
      before do
        organization.download_reviewer = [user.ms_id, user2.ms_id]
        organization.save!
      end
      it 'returns the download_reviewer' do
        expect(organization.media_download_reviewers).to match_array([user.ms_id, user2.ms_id])
      end
    end

    context 'the organization has no download_reviewer' do
      context 'the organization has managers' do
        before do
          organization.managers << user
          organization.managers << user2
          organization.managers_group.save!
        end
        it 'returns the ms_ids of the organization managers' do
          expect(organization.media_download_reviewers).to match_array([user.ms_id, user2.ms_id])
        end
      end

      context 'the organization has no managers' do
        it 'returns an empty array' do
          expect(organization.media_download_reviewers).to eq([])
        end
      end
    end
  end
end

describe 'agreement attachment methods' do
  let(:organization) { Organization.create }
  let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
  let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
  let(:valid_file_upload_url_for_org_coll) { "/uploads/works/organization/attachments/agreement/text.txt" }

  describe '#agreement_uploader' do
    it 'initializes an agreement_uploader with the correct work_id' do
      agreement_uploader = organization.agreement_uploader
      expect(agreement_uploader).to be_an_instance_of(OrganizationAgreementAttachmentUploader)
      expect(agreement_uploader.work_id).to eq(organization.id)
    end
  end

  describe '#agreement_attachment=' do
    context 'when assigning a valid file' do
      it 'stores the file and sets the agreement_attachment_url' do
        organization.agreement_attachment = valid_file
        expect(organization.agreement_attachment_url).to eq(valid_file_upload_url_for_org_coll)
        expect(File.exist?(organization.agreement_uploader.file.path)).to be_truthy
      end
    end

    context 'when assigning an invalid file' do
      it 'raises an error for unsupported file format' do
        expect {
          organization.agreement_attachment = invalid_file
        }.to raise_error(ArgumentError, /Invalid file format: .jpg/)
      end
    end

    context 'when assigning nil' do
      before do
        organization.agreement_attachment = valid_file
        expect(organization.agreement_attachment_url).to be_present
      end

      it 'deletes the attachment and clears the agreement_attachment_url' do
        file_path = organization.agreement_uploader.file.path
        expect(File.exist?(file_path)).to be_truthy

        organization.agreement_attachment = nil
        expect(organization.agreement_attachment_url).to be_nil
        expect(File.exist?(file_path)).to be_falsey
      end

      it 'logs a warning if the file does not exist' do
        allow(File).to receive(:exist?).and_return(false)
        organization.agreement_attachment = nil
      end
    end
  end

  describe '#agreement_attachment' do
    it 'returns the agreement_attachment_url' do
      organization.agreement_attachment = valid_file
      expect(organization.agreement_attachment).to eq(organization.agreement_attachment_url)
    end
  end
end

describe 'agreement attachment methods for OrganizationCollection' do
  let(:organization_collection) { OrganizationCollection.create }
  let(:valid_file) { Rack::Test::UploadedFile.new('spec/fixtures/text/text.txt', 'text/plain') }
  let(:invalid_file) { Rack::Test::UploadedFile.new('spec/fixtures/images/ms.jpg', 'application/jpeg') }
  let(:valid_file_upload_url_for_org_coll) { "/uploads/collections/organization_collection/attachments/agreement/text.txt" }

  describe '#agreement_uploader' do
    it 'initializes an agreement_uploader with the correct collection_id' do
      agreement_uploader = organization_collection.agreement_uploader
      expect(agreement_uploader).to be_an_instance_of(OrganizationCollectionAgreementAttachmentUploader)
      expect(agreement_uploader.collection_id).to eq(organization_collection.id)
    end
  end

  describe '#agreement_attachment=' do
    context 'when assigning a valid file' do
      it 'stores the file and sets the agreement_attachment_url' do
        organization_collection.agreement_attachment = valid_file
        expect(organization_collection.agreement_attachment_url).to eq(valid_file_upload_url_for_org_coll)
        expect(File.exist?(organization_collection.agreement_uploader.file.path)).to be_truthy
      end
    end

    context 'when assigning an invalid file' do
      it 'raises an error for unsupported file format' do
        expect {
          organization_collection.agreement_attachment = invalid_file
        }.to raise_error(ArgumentError, /Invalid file format: .jpg/)
      end
    end

    context 'when assigning nil' do
      before do
        organization_collection.agreement_attachment = valid_file
        expect(organization_collection.agreement_attachment_url).to be_present
      end

      it 'deletes the attachment and clears the agreement_attachment_url' do
        file_path = organization_collection.agreement_uploader.file.path
        expect(File.exist?(file_path)).to be_truthy

        organization_collection.agreement_attachment = nil
        expect(organization_collection.agreement_attachment_url).to be_nil
        expect(File.exist?(file_path)).to be_falsey
      end

      it 'logs a warning if the file does not exist' do
        allow(File).to receive(:exist?).and_return(false)
        organization_collection.agreement_attachment = nil
      end
    end
  end

  describe '#agreement_attachment' do
    it 'returns the agreement_attachment_url' do
      organization_collection.agreement_attachment = valid_file
      expect(organization_collection.agreement_attachment).to eq(organization_collection.agreement_attachment_url)
    end
  end

  describe '#continent' do
    let(:organization)      { OrganizationCollection.new }
    let(:organization_work) { Organization.new }

    context 'the organization does not have a country' do
      it 'returns an empty array' do
        expect(organization.continent).to eq([])
        expect(organization_work.continent).to eq([])
      end
    end

    context 'the organization has a country' do
      before do
        organization.country = ['United States']
        organization_work.country = ['United States']
      end
      it 'returns the continent' do
        expect(organization.continent).to eq(['North America'])
        expect(organization_work.continent).to eq(['North America'])
      end
    end
  end
end
