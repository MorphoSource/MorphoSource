# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::HomepageController, type: :controller do
  describe '#index' do
    context 'featured_projects' do
      let(:guest)   { FactoryBot.build(:user, :guest) }

      let!(:projectA)               { Collection.create(id: 'projectA', title: ['Project_A'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let!(:projectB)               { Collection.create(id: 'projectB', title: ['Project_B'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let!(:projectC)               { Collection.create(id: 'projectC', title: ['Project_C'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let!(:projectD)               { Collection.create(id: 'projectD', title: ['Project_D'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let!(:projectE)               { Collection.create(id: 'projectE', title: ['Project_E'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let!(:projectF)               { Collection.create(id: 'projectF', title: ['Project_F'], collection_type_gid: project_collection_type.to_global_id, visibility: 'open') }
      let(:all_project_ids)         { [projectA.id, projectB.id, projectC.id, projectD.id, projectE.id, projectF.id] }
      let(:selected_project_ids)    { [projectA.id, projectC.id, projectE.id] }

      before do
        sign_in guest
      end

      it 'returns appropriate projects' do
        # no featured projects configured
        Rails.application.config.featured_project_ids = []
        get :index
        expect(controller.instance_variable_get(:@featured_projects).map(&:id)).to match_array(all_project_ids)
        
        # findable featured projects configured
        controller.instance_variable_set(:@featured_projects, nil)
        Rails.application.config.featured_project_ids = selected_project_ids
        get :index
        expect(controller.instance_variable_get(:@featured_projects).map(&:id)).to match_array(selected_project_ids)
        
        # un-findable featured projects configured
        controller.instance_variable_set(:@featured_projects, nil)
        Rails.application.config.featured_project_ids = ['A','B','C']
        get :index
        expect(controller.instance_variable_get(:@featured_projects).map(&:id)).to match_array(all_project_ids)
      end
    end
  end
end