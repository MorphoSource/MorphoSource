# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionsControllerExportBehavior, type: :controller do
  render_views

  let(:organizations_controller)            { Morphosource::Collections::OrganizationCollectionsController.new }
  let(:device_media_controller)             { Morphosource::Collections::OrganizationCollections::DeviceMediaController.new }
  let(:organization_specimens_controller)   { Morphosource::Collections::OrganizationCollections::PhysicalObjects::BiologicalSpecimensController.new }
  let(:organization_chos_controller)        { Morphosource::Collections::OrganizationCollections::PhysicalObjects::CulturalHeritageObjectsController.new }
  let(:devices_controller)                  { Morphosource::Collections::OrganizationCollections::DevicesController.new }

  let(:teams_controller)                    { Morphosource::Collections::TeamsController.new }
  let(:projects_controller)                 { Morphosource::Collections::ProjectsController.new }
  let(:media_lists_controller)              { Morphosource::Collections::MediaListsController.new }
  let(:sequential_section_lists_controller) { Morphosource::Collections::MediaLists::SequentialSectionListsController.new }
  let(:specimens_controller)                { Morphosource::Collections::BiologicalSpecimensController.new }
  let(:chos_controller)                     { Morphosource::Collections::CulturalHeritageObjectsController.new }

  describe 'export filenames' do
    let(:default_works_export_filename)           { "#{document_type.titleize.pluralize} Query" }
    let(:default_media_download_counts_filename)  { "Media%20Download%20Counts" }
    let(:default_media_downloads_filename)        { "Media%20Downloads" }
    let(:default_media_requests_filename)         { "Media%20Requests" }

    let(:document_type) { "media" }

    before do
      subject.instance_variable_set(:@document_type, document_type)
    end

    context 'collection is an organization' do
      subject { organizations_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_export.filename"))}
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_download_counts.filename"))}
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_downloads.filename"))}
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_requests.filename"))}
      end
    end

    context 'controller is a device media controller' do
      subject { device_media_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(I18n.t("morphosource.collections.organization.exports.device_media.media_export.filename")) }
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(I18n.t("morphosource.collections.organization.exports.device_media.media_download_counts.filename"))}
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(I18n.t("morphosource.collections.organization.exports.device_media.media_downloads.filename"))}
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(I18n.t("morphosource.collections.organization.exports.device_media.media_requests.filename"))}
      end
    end

    context 'collection is a media list' do
      subject { media_lists_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(I18n.t("morphosource.collections.media_list.exports.media.media_export.filename"))}
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(I18n.t("morphosource.collections.media_list.exports.media.media_download_counts.filename"))}
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(I18n.t("morphosource.collections.media_list.exports.media.media_downloads.filename"))}
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(I18n.t("morphosource.collections.media_list.exports.media.media_requests.filename"))}
      end
    end

    context 'collection is a sequential section list' do
      subject { sequential_section_lists_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(I18n.t("morphosource.collections.sequential_section_list.exports.media.media_export.filename"))}
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(I18n.t("morphosource.collections.sequential_section_list.exports.media.media_download_counts.filename"))}
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(I18n.t("morphosource.collections.sequential_section_list.exports.media.media_downloads.filename"))}
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(I18n.t("morphosource.collections.sequential_section_list.exports.media.media_requests.filename"))}
      end
    end

    context 'collection is a team' do
      subject { teams_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(default_media_download_counts_filename) }
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(default_media_downloads_filename) }
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(default_media_requests_filename)}
      end
    end

    context 'collection is a project' do
      subject { projects_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end

      describe 'media_download_counts_filename' do
        it { expect(subject.send(:media_download_counts_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_download_counts_filename)).to eq(default_media_download_counts_filename) }
      end

      describe 'media_downloads_filename' do
        it { expect(subject.send(:media_downloads_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_downloads_filename)).to eq(default_media_downloads_filename) }
      end

      describe 'media_requests_filename' do
        it { expect(subject.send(:media_requests_filename)).not_to include('translation missing') }
        it { expect(subject.send(:media_requests_filename)).to eq(default_media_requests_filename)}
      end
    end

    context 'controller is an organization devices controller' do
      let(:document_type) { "device" }
      subject { devices_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end
    end

    context 'controller is a biological specimens controller' do
      let(:document_type) { "object" }
      subject { specimens_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end
    end

    context 'controller is an organization biological specimens controller' do
      let(:document_type) { "object" }
      subject { organization_specimens_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end
    end

    context 'controller is an organization cultural heritage objects controller' do
      let(:document_type) { "object" }
      subject { organization_chos_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end
    end

    context 'controller is a cultural heritage objects controller' do
      let(:document_type) { "object" }
      subject { chos_controller }

      describe 'works_export_filename' do
        it { expect(subject.send(:works_export_filename)).not_to include('translation missing') }
        it { expect(subject.send(:works_export_filename)).to eq(default_works_export_filename) }
      end
    end
  end

  describe 'csv exports' do
    let(:admin)                   { FactoryBot.create(:admin) }
    let(:project)                 { FactoryBot.create(:project, depositor: admin.ms_id) }
    let(:organization)            { FactoryBot.create(:organization_collection, depositor: admin.ms_id) }
    let(:object)                  { FactoryBot.create(:biological_specimen) }
    let(:device)                  { FactoryBot.create(:device) }
    let(:imaging_event)           { FactoryBot.create(:imaging_event, ie_modality: device.modality, device_id: [device.id], physical_object_id: [object.id]) }
    let(:media)                   { FactoryBot.create(:media, visibility: 'open') }
    let!(:cart_item)              { CartItem.create(work_id: media.id, user_id: admin.ms_id, date_downloaded: Date.yesterday, date_requested: Date.yesterday) }
    let(:relation)                { CartItem.where(work_id: media.id) }
    let(:user)                    { FactoryBot.create(:user) }
    let(:collections_controller)  { Morphosource::CollectionsController.new }

    before do
      imaging_event.ordered_members << media
      imaging_event.save!
      allow(CartItem).to receive(:where).with( { :work_id=>[media.id] } ).and_return(relation)
    end

    context 'user is not authorized' do
      context 'user is not signed in' do
        it 'redirects the user' do
          # objects_export
          @controller = specimens_controller
          get :objects_export, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # devices_export
          @controller = devices_controller
          get :devices_export, params: { id: organization.id }, format: :csv
          expect(response.status).to eq(302)
          # media_export
          @controller = collections_controller
          get :media_export, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_downloads
          get :media_downloads, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_download_counts
          get :media_download_counts, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_requests
          get :media_requests, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
        end
      end

      context 'user can not edit collection' do
        before do
          sign_in user
        end
        it 'redirects the user' do
          # objects_export
          @controller = specimens_controller
          get :objects_export, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # devices_export
          @controller = devices_controller
          get :devices_export, params: { id: organization.id }, format: :csv
          expect(response.status).to eq(302)
          # media_export
          @controller = collections_controller
          get :media_export, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_downloads
          get :media_downloads, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_download_counts
          get :media_download_counts, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
          # media_requests
          get :media_requests, params: { id: project.id }, format: :csv
          expect(response.status).to eq(302)
        end
      end
    end

    context 'user is authorized' do
      let(:manager) { User.find(user.id) } # reload user after adding collection manager role

      before do
        [project, organization].each do |collection|
          collection.create_collection_groups
          Morphosource::Collections::PermissionsCreateService.create_default(collection: collection)
          collection.managers << user
          collection.save!
        end
        sign_in manager
      end

      context 'collection is empty' do
        let!(:device) { FactoryBot.create(:device) }

        it 'returns an empty csv' do
          # objects_export
          @controller = specimens_controller
          get :objects_export, params: { id: project.id }, format: :csv
          expect(response.body).to be_empty
          # devices_export
          @controller = devices_controller
          get :devices_export, params: { id: organization.id }, format: :csv
          expect(response.body).to be_empty
          # media_export
          @controller = collections_controller
          get :media_export, params: { id: project.id }, format: :csv
          expect(response.body).to be_empty
          # media_downloads
          get :media_downloads, params: { id: project.id }, format: :csv
          expect(response.body).to be_empty
          # media_download_counts
          get :media_download_counts, params: { id: project.id }, format: :csv
          expect(response.body).to be_empty
          # media_requests
          get :media_requests, params: { id: project.id }, format: :csv
          expect(response.body).to be_empty
        end
      end

      context 'collection is not empty' do
        let!(:device) { FactoryBot.create(:device, organization_id: [organization.id]) }

        before do
          media.member_of_collections << project
          media.save!
        end

        it 'returns a csv with data' do
          # objects_export
          @controller = specimens_controller
          get :objects_export, params: { id: project.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(object.id)
          # devices_export
          @controller = devices_controller
          get :devices_export, params: { id: organization.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(device.id)
          # media_export
          @controller = collections_controller
          get :media_export, params: { id: project.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(media.id)
          # media_downloads
          get :media_downloads, params: { id: project.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(media.id)
          # media_download_counts
          get :media_download_counts, params: { id: project.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(media.id)
          # media_requests
          get :media_requests, params: { id: project.id }, format: :csv
          rows = CSV.new(response.body).read
          expect(rows.count).to eq(2) # header row + data row
          expect(rows.last.compact.map(&:strip)).to include(media.id)
        end
      end
    end
  end
end
