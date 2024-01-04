# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::CollectionsControllerExportBehavior, type: :controller do

  let(:organization_controller) { Morphosource::Collections::OrganizationCollectionsController.new }
  let(:team_controller) { Morphosource::Collections::TeamsController.new }
  let(:document_type) { "media" }

  describe 'works_export_filename' do
    context 'collection is an organization' do
      subject { organization_controller }
      it 'returns the correct filename' do
        expect(subject.send(:works_export_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_export.filename"))
      end
    end
    context 'collection is not an organization' do
      subject { team_controller }
      before do
        subject.instance_variable_set(:@document_type, document_type)
      end
      it 'returns the correct filename' do
        expect(subject.send(:works_export_filename)).to eq("#{document_type.titleize.pluralize} Query")
      end
    end
  end

  describe 'media_download_counts_filename' do
    context 'collection is an organization' do
      subject { organization_controller }
      it 'returns the correct filename' do
        expect(subject.send(:media_download_counts_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_download_counts.filename"))
      end
    end
    context 'collection is not an organization' do
      subject { team_controller }

      it 'returns the correct filename' do
        expect(subject.send(:media_download_counts_filename)).to eq('Media%20Download%20Counts')
      end
    end
  end

  describe 'media_downloads_filename' do
    context 'collection is an organization' do
      subject { organization_controller }

      it 'returns the correct filename' do
        expect(subject.send(:media_downloads_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_downloads.filename"))
      end
    end
    context 'collection is not an organization' do
      subject { team_controller }

      it 'returns the correct filename' do
        expect(subject.send(:media_downloads_filename)).to eq('Media%20Downloads')
      end
    end
  end

  describe 'media_requests_filename' do
    context 'collection is an organization' do
      subject { organization_controller }

      it 'returns the correct filename' do
        expect(subject.send(:media_requests_filename)).to eq(I18n.t("morphosource.collections.organization.exports.media.media_requests.filename"))
      end
    end
    context 'collection is not an organization' do
      subject { team_controller }

      it 'returns the correct filename' do
        expect(subject.send(:media_requests_filename)).to eq('Media%20Requests')
      end
    end
  end
end
