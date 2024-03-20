require 'rails_helper'

RSpec.describe Morphosource::Dashboard::CollectionsHelper, type: :helper do
  include Rails.application.routes.url_helpers

  let(:user)                    { FactoryBot.create(:contributor) }
  let(:team)                    { FactoryBot.create(:team, depositor: user.ms_id) }
  let(:project)                 { FactoryBot.create(:project, depositor: user.ms_id) }
  let(:media_list)              { FactoryBot.create(:media_list, depositor: user.ms_id) }
  let(:sequential_section_list) { FactoryBot.create(:sequential_section_list, depositor: user.ms_id) }
  let(:organization)            { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

  let(:collections)             { [team, project, media_list, sequential_section_list, organization] }

  describe 'tab_urls' do
    it 'returns the correct path for each collection type' do
      collections.each do |collection|
        collection_type = collection.collection_type.machine_id
        # details_tab_url
        expect(helper.details_tab_url(collection)).to eq(main_app.send("#{collection_type}_edit_path", collection))
        # members_tab_url
        expect(helper.members_tab_url(collection)).to eq(main_app.send("#{collection_type}_members_path", collection))
        # permissions_tab_url
        expect(helper.permissions_tab_url(collection)).to eq(main_app.organization_permissions_path(collection))
        # projects_tab_url
        if collection_type == 'team' || collection_type == 'organization'
          expect(helper.projects_tab_url(collection)).to eq(main_app.send("#{collection_type}_projects_path", collection))
        end
        # organization_tab_url
        if collection_type == 'team'
          expect(helper.organization_tab_url(collection)).to eq(main_app.team_organization_path(collection))
        end
        # new_collection_url
        expect(helper.new_collection_url(collection_type.pluralize)).to eq(main_app.send("new_#{collection_type}_path"))
      end
    end
  end
end