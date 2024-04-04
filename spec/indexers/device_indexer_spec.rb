require 'rails_helper'

RSpec.describe DeviceIndexer do
  let(:device)              { Device.create(title: ['device']) }
  subject(:solr_document)   { described_class.new(device).generate_solr_document }

  describe 'generate_solr_document' do
    before do
      device.creator = ['creator']
      device.ark = ["ark:/12345/m4/678910"]
    end
    it 'indexes device fields' do
      expect(subject["creator_ssim"]).to match_array(device.creator)
      expect(subject['ark_ssim']).to match_array(device.ark)
      expect(subject['ark_tesim']).to match_array(device.ark)
    end
  end

  describe 'organization fields' do
    context 'organization is a work' do
      let(:organization)  { FactoryBot.create(:organization, title: ['organization work'], institution_name: ['institution name']) }

      before do
        organization.ordered_members << device
        organization.save!
      end

      it 'indexes organization fields' do
        expect(subject["device_organization_id_tesim"]).to eq(organization.id)
        expect(subject["device_organization_id_ssim"]).to eq(organization.id)
        expect(subject["device_organization_title_tesim"]).to match_array(organization.title)
        expect(subject["device_organization_title_ssi"]).to match_array(organization.title)
        expect(subject["device_organization_institution_name_tesim"]).to match_array(organization.institution_name)
        expect(subject["device_organization_institution_name_ssim"]).to match_array(organization.institution_name)
      end
    end

    context 'organization is a collection' do
      let(:user)          { FactoryBot.create(:contributor) }
      let(:organization)  { FactoryBot.create(:organization_collection, title: ['organization work'], institution_name: ['institution name'], depositor: user.ms_id) }

      before do
        device.organization_id = [organization.id]
        device.save!
      end

      it 'indexes organization fields' do
        expect(subject["device_organization_id_tesim"]).to eq(organization.id)
        expect(subject["device_organization_id_ssim"]).to eq(organization.id)
        expect(subject["device_organization_title_tesim"]).to match_array(organization.title)
        expect(subject["device_organization_title_ssi"]).to match_array(organization.title)
        expect(subject["device_organization_institution_name_tesim"]).to match_array(organization.institution_name)
        expect(subject["device_organization_institution_name_ssim"]).to match_array(organization.institution_name)
      end
    end
  end
end