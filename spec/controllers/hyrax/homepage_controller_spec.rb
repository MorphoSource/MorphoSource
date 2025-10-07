# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::HomepageController, type: :controller do
  describe '#index' do
    context 'featured_projects' do
      let(:homepage_form)             { Morphosource::Forms::Admin::Homepage.new }

      let!(:project)                  { FactoryBot.create(:project_document) }
      let!(:projectA)                 { FactoryBot.create(:project_document) }
      let!(:projectB)                 { FactoryBot.create(:project_document) }
      let!(:projectC)                 { FactoryBot.create(:project_document) }

      let!(:team)                     { FactoryBot.create(:team_document) }
      let!(:organization)             { FactoryBot.create(:organization_collection_document) }
      let!(:media_list)               { FactoryBot.create(:media_list_document) }
      let!(:sequential_section_list)  { FactoryBot.create(:sequential_section_list_document) }

      let(:all_project_team_ids)      { [project.id, projectA.id, projectB.id, projectC.id, team.id] }
      let(:selected_collection_ids)   { [project.id, organization.id, media_list.id] }

      context 'when no featured collections are configured' do
        it 'returns 5 projects/teams' do
          get :index
          expect(controller.instance_variable_get(:@featured_collections).map(&:id)).to match_array(all_project_team_ids)
        end
      end

      context 'when findable featured collections are configured' do
        before do
          homepage_form.send(:update_block,"featured_collections", selected_collection_ids.join(","))
        end

        it 'returns the selected collections' do
          get :index
          expect(controller.instance_variable_get(:@featured_collections).map(&:id)).to match_array(selected_collection_ids)
        end
      end

      context 'when un-findable featured collections are configured' do
        let(:bogus_ids) { ['bogus1', 'bogus2'] }
        before do
          homepage_form.send(:update_block,"featured_collections", (selected_collection_ids + bogus_ids).join(","))
        end

        it 'returns only the findable selected collections' do
          get :index
          expect(controller.instance_variable_get(:@featured_collections).map(&:id)).to match_array(selected_collection_ids)
        end
      end
    end
  end
end