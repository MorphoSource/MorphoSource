require 'rails_helper'

RSpec.describe Hyrax::Browse::BrowseOrganizationsHelper, type: :helper do

  let!(:org1)  { 
    Organization.create(
      title: ['title'], 
      organization_type: ["Scanning Facility"]
    ) 
  }
  let!(:org2)  { 
    Organization.create(
      title: ['title'], 
      organization_type: ["Collection and Scanning Facility"]
    ) 
  }

  before do
    allow(helper).to receive(:browse_service) { Morphosource::BrowseService.new }
    get_organization_count_by_type
  end

  describe '@org_type_and_count' do
    it 'returns org type and count' do
      expect(@org_type_and_count["Scanning Facility"]).to eq(1)
      expect(@org_type_and_count["Collection and Scanning Facility"]).to eq(1)
    end
  end

end

