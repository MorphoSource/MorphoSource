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
  end

#  describe 'total_scanning_facilities' do
#    it 'returns org count with Scanning Facilities' do
#      expect(total_scanning_facilities).to eq(1)
#    end
#
#    it 'returns org count with Collection & Scanning Facilities' do
#      expect(total_collection_and_scanning_facilities).to eq(1)
#    end
#  end

end

