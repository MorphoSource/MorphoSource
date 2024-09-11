# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionsControllerExportBehavior, type: :controller do

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
end
