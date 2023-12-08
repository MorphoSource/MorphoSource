# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionRolesHelper, type: :helper do
  let(:user)    { User.create(email: 'user@email.com', password: 'password') }
  let(:params)  { {"f"=>{"publication_status_ssi"=>["Open Download"]}, "locale"=>"en"} }

  before do
    allow(helper).to receive_message_chain(:request, :parameters).and_return(params)
  end

  describe 'team paths' do
    let!(:collection)            { Collection.create(title: ['team'], collection_type_gid: team_collection_type.gid, depositor: user.ms_id) }


    it 'has all the correct paths' do
      expect(helper.media_tab_url(collection)).to eq("/teams/#{collection.id}")
      expect(helper.specimens_tab_url(collection)).to eq("/teams/#{collection.id}/biological_specimens")
      expect(helper.chos_tab_url(collection)).to eq("/teams/#{collection.id}/cultural_heritage_objects")
      expect(helper.about_tab_url(collection)).to eq("/teams/#{collection.id}/about")
      expect(helper.members_tab_url(collection)).to eq("/dashboard/teams/#{collection.id}/members")
      expect(helper.chos_export_csv_url(collection)).to eq("/teams/#{collection.id}/cultural_heritage_objects/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.specimens_export_csv_url(collection)).to eq("/teams/#{collection.id}/biological_specimens/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_export_csv_url(collection)).to eq("/teams/#{collection.id}/media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_downloads_csv_url(collection)).to eq("/teams/#{collection.id}/media_downloads.csv?per_page=1000000")
      expect(helper.media_download_counts_csv_url(collection)).to eq("/teams/#{collection.id}/media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_requests_csv_url(collection)).to eq("/teams/#{collection.id}/media_requests.csv?per_page=1000000")
      expect(helper.collection_media_path(collection)).to eq("/teams/#{collection.id}")
      expect(helper.collection_edit_path(collection)).to eq("/dashboard/teams/#{collection.id}")
      expect(helper.update_collection_path(collection)).to eq("/dashboard/teams/#{collection.id}")
      expect(helper.my_collections_type_path(collection)).to eq("/dashboard/my/teams")
    end
  end

  describe 'project paths' do
    let(:collection)              { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

    it 'has all the correct paths' do
      expect(helper.media_tab_url(collection)).to eq("/projects/#{collection.id}")
      expect(helper.specimens_tab_url(collection)).to eq("/projects/#{collection.id}/biological_specimens")
      expect(helper.chos_tab_url(collection)).to eq("/projects/#{collection.id}/cultural_heritage_objects")
      expect(helper.about_tab_url(collection)).to eq("/projects/#{collection.id}/about")
      expect(helper.chos_export_csv_url(collection)).to eq("/projects/#{collection.id}/cultural_heritage_objects/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.specimens_export_csv_url(collection)).to eq("/projects/#{collection.id}/biological_specimens/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_export_csv_url(collection)).to eq("/projects/#{collection.id}/media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_downloads_csv_url(collection)).to eq("/projects/#{collection.id}/media_downloads.csv?per_page=1000000")
      expect(helper.media_download_counts_csv_url(collection)).to eq("/projects/#{collection.id}/media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_requests_csv_url(collection)).to eq("/projects/#{collection.id}/media_requests.csv?per_page=1000000")
      expect(helper.collection_media_path(collection)).to eq("/projects/#{collection.id}")
      expect(helper.collection_edit_path(collection)).to eq("/dashboard/projects/#{collection.id}")
      expect(helper.members_tab_url(collection)).to eq("/dashboard/projects/#{collection.id}/members")
      expect(helper.update_collection_path(collection)).to eq("/dashboard/projects/#{collection.id}")
      expect(helper.my_collections_type_path(collection)).to eq("/dashboard/my/projects")
    end
  end

  describe 'media list paths' do
    let(:collection)                  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: user.ms_id) }

    it 'has all the correct paths' do
      expect(helper.media_tab_url(collection)).to eq("/media_lists/#{collection.id}")
      expect(helper.specimens_tab_url(collection)).to eq("/media_lists/#{collection.id}/biological_specimens")
      expect(helper.chos_tab_url(collection)).to eq("/media_lists/#{collection.id}/cultural_heritage_objects")
      expect(helper.about_tab_url(collection)).to eq("/media_lists/#{collection.id}/about")
      expect(helper.chos_export_csv_url(collection)).to eq("/media_lists/#{collection.id}/cultural_heritage_objects/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.specimens_export_csv_url(collection)).to eq("/media_lists/#{collection.id}/biological_specimens/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_export_csv_url(collection)).to eq("/media_lists/#{collection.id}/media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_downloads_csv_url(collection)).to eq("/media_lists/#{collection.id}/media_downloads.csv?per_page=1000000")
      expect(helper.media_download_counts_csv_url(collection)).to eq("/media_lists/#{collection.id}/media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_requests_csv_url(collection)).to eq("/media_lists/#{collection.id}/media_requests.csv?per_page=1000000")
      expect(helper.collection_media_path(collection)).to eq("/media_lists/#{collection.id}")
      expect(helper.collection_edit_path(collection)).to eq("/dashboard/media_lists/#{collection.id}")
      expect(helper.members_tab_url(collection)).to eq("/dashboard/media_lists/#{collection.id}/members")
      expect(helper.update_collection_path(collection)).to eq("/dashboard/media_lists/#{collection.id}")
      expect(helper.my_collections_type_path(collection)).to eq("/dashboard/my/media_lists")
    end
  end

  describe 'sequential section list paths' do
    let(:collection)                              { SequentialSectionList.create(title: ['sequential section list'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: user.ms_id) }

    it 'has all the correct paths' do
      expect(helper.media_tab_url(collection)).to eq("/sequential_section_lists/#{collection.id}")
      expect(helper.specimens_tab_url(collection)).to eq("/sequential_section_lists/#{collection.id}/biological_specimens")
      expect(helper.chos_tab_url(collection)).to eq("/sequential_section_lists/#{collection.id}/cultural_heritage_objects")
      expect(helper.about_tab_url(collection)).to eq("/sequential_section_lists/#{collection.id}/about")
      expect(helper.chos_export_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/cultural_heritage_objects/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.specimens_export_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/biological_specimens/objects_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_export_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_downloads_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/media_downloads.csv?per_page=1000000")
      expect(helper.media_download_counts_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_requests_csv_url(collection)).to eq("/sequential_section_lists/#{collection.id}/media_requests.csv?per_page=1000000")
      expect(helper.collection_media_path(collection)).to eq("/sequential_section_lists/#{collection.id}")
      expect(helper.collection_edit_path(collection)).to eq("/dashboard/sequential_section_lists/#{collection.id}")
      expect(helper.members_tab_url(collection)).to eq("/dashboard/sequential_section_lists/#{collection.id}/members")
      expect(helper.update_collection_path(collection)).to eq("/dashboard/sequential_section_lists/#{collection.id}")
      expect(helper.my_collections_type_path(collection)).to eq("/dashboard/my/sequential_section_lists")
    end
  end

  describe 'organization paths' do
    let(:collection)  { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

    it 'has all the correct paths' do
      # object media tab
      expect(helper.media_tab_url(collection)).to eq("/organizations/#{collection.id}")
      expect(helper.media_export_csv_url(collection)).to eq("/organizations/#{collection.id}/media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_downloads_csv_url(collection)).to eq("/organizations/#{collection.id}/media_downloads.csv?per_page=1000000")
      expect(helper.media_download_counts_csv_url(collection)).to eq("/organizations/#{collection.id}/media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.media_requests_csv_url(collection)).to eq("/organizations/#{collection.id}/media_requests.csv?per_page=1000000")
      expect(helper.collection_media_path(collection)).to eq("/organizations/#{collection.id}")

      # device media tab
      helper.instance_variable_set(:@tab, :device_media)
      expect(helper.device_media_export_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.device_media_downloads_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_downloads.csv?per_page=1000000")
      expect(helper.device_media_download_counts_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.device_media_requests_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_requests.csv?per_page=1000000")

      expect(helper.device_media_tab_url(collection)).to eq("/organizations/#{collection.id}/device-media")
      expect(helper.device_media_export_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_export.csv?#{params.to_query}&per_page=1000000")
      expect(helper.device_media_downloads_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_downloads.csv?per_page=1000000")
      expect(helper.device_media_download_counts_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_download_counts.csv?#{params.to_query}&per_page=1000000")
      expect(helper.device_media_requests_csv_url(collection)).to eq("/organizations/#{collection.id}/device_media_requests.csv?per_page=1000000")

      # specimens tab
      expect(helper.specimens_tab_url(collection)).to eq("/organizations/#{collection.id}/biological-specimens")
      expect(helper.specimens_export_csv_url(collection)).to eq("/organizations/#{collection.id}/biological_specimens/objects_export.csv?#{params.to_query}&per_page=1000000")

      # chos tab
      expect(helper.chos_tab_url(collection)).to eq("/organizations/#{collection.id}/cultural-heritage-objects")
      expect(helper.chos_export_csv_url(collection)).to eq("/organizations/#{collection.id}/cultural_heritage_objects/objects_export.csv?#{params.to_query}&per_page=1000000")

      # devices tab
      expect(helper.devices_tab_url(collection)).to eq("/organizations/#{collection.id}/devices")

      # about tab
      expect(helper.about_tab_url(collection)).to eq("/organizations/#{collection.id}/about")

      # edit
      expect(helper.collection_edit_path(collection)).to eq("/dashboard/organizations/#{collection.id}")
      expect(helper.members_tab_url(collection)).to eq("/dashboard/organizations/#{collection.id}/members")
      expect(helper.update_collection_path(collection)).to eq("/dashboard/organizations/#{collection.id}")

      # my organizations
      expect(helper.my_collections_type_path(collection)).to eq("/dashboard/my/organizations")
    end

  end
end