require 'rails_helper'

RSpec.describe Hyrax::TeamPresenter do

  let(:ability) { double Ability }

  let(:team_collection_type) { Hyrax::CollectionType.create(title: 'Team', machine_id: 88) }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project', machine_id: 77) }
  let(:another_collection_type) { Hyrax::CollectionType.create(title: 'Another', machine_id: 99) }
  let(:user) { User.create(display_name: 'John Doe', email: 'johndoe@email.com', password: 'password', ms_id: 'abc123') }

  let(:team) { Collection.create(title: ['Team_B'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }

  let(:project) { Collection.create(title: ['Project_B'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

  let(:role) { Role.new(name: 'role') }
  
  let!(:org1)  { 
  	Organization.create(
  		title: ['title'], 
      institution_name: ["institution_name"],
      institution_code: ["institution_code"],
      collection_code: ["collection_code"],
      description: ["description"],
      address: ["address"],
      city: ["city"],
      state_province: ["state_province"],
      country: ["country"],
  		team_id: [team.id]
  	) 
  }


  before do
    allow(Role).to receive(:find_by).and_return(role)
    team.create_collection_groups
  end

	let(:presenter) { described_class.new(SolrDocument.new(team.to_solr), ability, nil) }


  describe "presenter methods" do 
    subject { presenter }
    it '#set_organization_data' do
    	expect(presenter.organization_title.first).to eq('title')
      expect(presenter.organization_institution_name.first).to eq("institution_name")
      expect(presenter.organization_institution_code.first).to eq("institution_code")
      expect(presenter.organization_collection_code.first).to eq("collection_code")
      expect(presenter.organization_description.first).to eq("description")
      expect(presenter.organization_address.first).to eq("address")
      expect(presenter.organization_city.first).to eq("city")
      expect(presenter.organization_state_province.first).to eq("state_province")
      expect(presenter.organization_country.first).to eq("country")
  	end

  	it '#collection_type' do
			expect(presenter.collection_type.title).to eq("Team")
  	end

  	it '#manager_list' do
  		expect(presenter.manager_list(presenter.collection.managers)).to eq("<a href=\"/users/abc123\">John Doe</a>")
  	end
	
  end



  describe "metadata methods" do 
    subject { presenter }
	  it { is_expected.to delegate_method(:part).to(:solr_document) }
	  it { is_expected.to delegate_method(:media_type).to(:solr_document) }
  end


end



