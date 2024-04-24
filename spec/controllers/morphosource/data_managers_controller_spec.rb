require 'rails_helper'

RSpec.describe Morphosource::DataManagersController, type: :controller do

  let!(:aaa_user)          { FactoryBot.create(:user, display_name: 'AAA User') }
  let!(:bbb_user)          { FactoryBot.create(:user, display_name: 'BBB User') }
  let!(:ccc_user)          { FactoryBot.create(:user, display_name: 'CCC User') }

  let!(:aaa_organization)  { FactoryBot.build(:organization_collection, id: 'aaa', title: ['AAA Organization'], institution_name: ['AAA Institution'], visibility: 'open') }
  let!(:bbb_organization)  { FactoryBot.build(:organization_collection, id: 'bbb', title: ['BBB Organization'], institution_name: ['BBB Institution'], visibility: 'open') }
  let!(:ccc_organization)  { FactoryBot.build(:organization_collection, id: 'ccc', title: ['CCC Organization'], institution_name: ['CCC Institution'], visibility: 'open') }

  before do
    [aaa_organization, bbb_organization, ccc_organization].each do |org|
      ActiveFedora::SolrService.add(org.to_solr, commit: true)
    end
  end

  describe 'GET #index' do
    it 'returns a list of users and organizations' do
      # returns users and organizations
      get :index, params: { uq: 'AAA' }, format: :json
      expect(controller.instance_variable_get(:@data_managers).map(&:id)).to match_array([aaa_user.id, aaa_organization.id])
      # returns users
      get :index, params: { uq: 'User' }, format: :json
      expect(controller.instance_variable_get(:@data_managers).map(&:id)).to match_array([aaa_user.id, bbb_user.id, ccc_user.id])
      # returns organizations - searches by title
      get :index, params: { uq: 'Organization' }, format: :json
      expect(controller.instance_variable_get(:@data_managers).map(&:id)).to match_array([aaa_organization.id, bbb_organization.id, ccc_organization.id])
      # returns organizations - searches by institution name
      get :index, params: { uq: 'Institution' }, format: :json
      expect(controller.instance_variable_get(:@data_managers).map(&:id)).to match_array([aaa_organization.id, bbb_organization.id, ccc_organization.id])
    end
  end
end