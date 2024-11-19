require 'rails_helper'

RSpec.describe Morphosource::HomepageHelper, type: :helper do

  describe 'featured_projects' do

    let(:guest)   { FactoryBot.build(:user, :guest) }
    let(:ability) { ::Ability.new(guest) }
    let(:scope)   { double(blacklight_config: CatalogController.blacklight_config, current_ability: ability) }

    let!(:projectA)               { Collection.create(id: 'projectA', title: ['Project_A'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let!(:projectB)               { Collection.create(id: 'projectB', title: ['Project_B'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let!(:projectC)               { Collection.create(id: 'projectC', title: ['Project_C'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let!(:projectD)               { Collection.create(id: 'projectD', title: ['Project_D'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let!(:projectE)               { Collection.create(id: 'projectE', title: ['Project_E'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let!(:projectF)               { Collection.create(id: 'projectF', title: ['Project_F'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
    let(:all_project_ids)         { [projectA.id, projectB.id, projectC.id, projectD.id, projectE.id, projectF.id] }
    let(:selected_project_ids)    { [projectA.id, projectC.id, projectE.id] }


    before do
      allow_any_instance_of(Blacklight::SearchBuilder).to receive(:scope).and_return(scope)
    end

    it 'returns appropriate projects' do
      # no featured projects configured
      Rails.application.config.featured_project_ids = []
      expect(ids(helper.featured_projects)).to match_array(all_project_ids)
      # findable featured projects configured
      Rails.application.config.featured_project_ids = selected_project_ids
      expect(ids(helper.featured_projects)).to match_array(selected_project_ids)
      # un-findable featured projects configured
      Rails.application.config.featured_project_ids = ['A','B','C']
      expect(ids(helper.featured_projects)).to match_array(all_project_ids)
    end
  end

  def ids(docs)
    docs.map(&:id)
  end

end
