require 'rails_helper'

RSpec.describe OrganizationIndexer do
  subject(:solr_document) { OrganizationIndexer.new(organization).generate_solr_document }
  let(:organization)      { Organization.create(title: ['organization title'], organization_type: ['Scanning Facility'], institution_name: ['Institution Name'], institution_code: ['Institution Code'], country: ['United States'], state_province: ['State'], city: ['City']) }

  describe 'custom fields' do
    it 'indexes organization_type' do
      expect(subject['organization_type_ssim']).to match_array(organization.organization_type)
    end

    it 'indexes institution_name' do
      expect(subject['institution_name_ssim']).to match_array(organization.institution_name)
    end

    it 'indexes institution_code' do
      expect(subject['institution_code_ssim']).to match_array(organization.institution_code)
    end

    it 'indexes country' do
      expect(subject['country_ssim']).to match_array(organization.country)
    end

    it 'indexes state_province' do
      expect(subject['state_province_ssim']).to match_array(organization.state_province)
    end

    it 'indexes city' do
      expect(subject['city_ssim']).to match_array(organization.city)
    end
  end
end
