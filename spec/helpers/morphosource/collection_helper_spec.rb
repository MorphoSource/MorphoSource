# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionRolesHelper, type: :helper do

  let(:user)                    { FactoryBot.create(:contributor) }
  let(:team)                    { FactoryBot.create(:team, depositor: user.ms_id) }
  let(:project)                 { FactoryBot.create(:project, depositor: user.ms_id) }
  let(:media_list)              { FactoryBot.create(:media_list, depositor: user.ms_id) }
  let(:sequential_section_list) { FactoryBot.create(:sequential_section_list, depositor: user.ms_id) }
  let(:organization)            { FactoryBot.create(:organization_collection, depositor: user.ms_id) }

  let(:collections)             { [team, project, media_list, sequential_section_list, organization] }

  before do
    allow(helper).to receive_message_chain(:request, :parameters).and_return({})
  end

  describe 'collection paths' do

    it 'has all the correct paths for each collection type' do
      collections.each do |collection|
        params = { :format => :csv, :per_page => 1000000 }.merge( { id: collection.id } )
        collection_type = collection.collection_type.machine_id

        # collection_media_path
        expect(helper.collection_media_path(collection)).to eq(main_app.send("#{collection_type}_path", collection))
        # collection_about_path
        expect(helper.collection_about_path(collection)).to eq(main_app.send("#{collection_type}_about_path", collection))
        # specimens_tab_url
        expect(helper.specimens_tab_url(collection)).to eq(main_app.send("#{collection_type}_specimens_path", collection))
        # chos_tab_url
        expect(helper.chos_tab_url(collection)).to eq(main_app.send("#{collection_type}_chos_path", collection))
        # about_tab_url
        expect(helper.about_tab_url(collection)).to eq(main_app.send("#{collection_type}_about_path", collection))
        # members_tab_url
        expect(helper.members_tab_url(collection)).to eq(main_app.send("#{collection_type}_members_path", collection))
        # chos_export_csv_url
        expect(helper.chos_export_csv_url(collection)).to eq(main_app.send("#{collection_type}_chos_export_path", params))
        # specimens_export_csv_url
        expect(helper.specimens_export_csv_url(collection)).to eq(main_app.send("#{collection_type}_specimens_export_path", params))
        # media_export_csv_url
        expect(helper.media_export_csv_url(collection)).to eq(main_app.send("#{collection_type}_media_export_path", params))
        # media_downloads_csv_url
        expect(helper.media_downloads_csv_url(collection)).to eq(main_app.send("#{collection_type}_media_downloads_path", params))
        # media_download_counts_csv_url
        expect(helper.media_download_counts_csv_url(collection)).to eq(main_app.send("#{collection_type}_media_download_counts_path", params))
        # media_requests_csv_url
        expect(helper.media_requests_csv_url(collection)).to eq(main_app.send("#{collection_type}_media_requests_path", params))
        # collection_edit_path
        expect(helper.collection_edit_path(collection)).to eq(main_app.send("#{collection_type}_edit_path", collection))
        # update_collection_path
        expect(helper.update_collection_path(collection)).to eq(main_app.send("update_#{collection_type}_path", collection))
        # my_collections_type_path
        expect(helper.my_collections_type_path(collection)).to eq(main_app.send("my_#{collection_type.pluralize}_path"))

        # organization specific paths
        if collection_type == 'organization'
          # devices_tab_url
          expect(helper.devices_tab_url(collection)).to eq(main_app.send("#{collection_type}_devices_path", collection))
          # device_media_tab_url
          expect(helper.device_media_tab_url(collection)).to eq(main_app.send("#{collection_type}_device_media_path", collection))
          # device_media_export_csv_url
          expect(helper.device_media_export_csv_url(collection)).to eq(main_app.send("#{collection_type}_device_media_export_path", params))
          # device_media_downloads_csv_url
          expect(helper.device_media_downloads_csv_url(collection)).to eq(main_app.send("#{collection_type}_device_media_downloads_path", params))
          # device_media_download_counts_csv_url
          expect(helper.device_media_download_counts_csv_url(collection)).to eq(main_app.send("#{collection_type}_device_media_download_counts_path", params))
          # device_media_requests_csv_url
          expect(helper.device_media_requests_csv_url(collection)).to eq(main_app.send("#{collection_type}_device_media_requests_path", params))
          # devices_export_csv_url
          expect(helper.devices_export_csv_url(collection)).to eq(main_app.send("#{collection_type}_devices_export_path", params))
        end
      end
    end
  end

  describe 'list_includes_specimens?' do
    let(:response)    { Morphosource::SolrService.new.get("has_model_ssim:Media", {"facet.field"=>["media_physical_object_type_ssim"]}) }

    context 'document list is only specimens' do
      let!(:media_doc1) { FactoryBot.create(:media_document) }
      let!(:media_doc2) { FactoryBot.create(:media_document) }
      let!(:media_doc3) { FactoryBot.create(:media_document) }

      it 'returns true' do
        expect(helper.response_includes_specimens?(response)).to be true
      end
    end

    context 'document list is only cultural heritage objects' do
      let!(:media_doc1) { FactoryBot.create(:cho_media_document) }
      let!(:media_doc2) { FactoryBot.create(:cho_media_document) }
      let!(:media_doc3) { FactoryBot.create(:cho_media_document) }

      it 'returns false' do
        expect(helper.response_includes_specimens?(response)).to be false
      end
    end

    context 'document list is a mix of specimens and cultural heritage objects' do
      let!(:media_doc1) { FactoryBot.create(:media_document) }
      let!(:media_doc2) { FactoryBot.create(:media_document) }
      let!(:media_doc3) { FactoryBot.create(:media_document) }
      let!(:media_doc4) { FactoryBot.create(:cho_media_document) }
      let!(:media_doc5) { FactoryBot.create(:cho_media_document) }
      let!(:media_doc6) { FactoryBot.create(:cho_media_document) }

      it 'returns true' do
        expect(helper.response_includes_specimens?(response)).to be true
      end
    end
  end
end