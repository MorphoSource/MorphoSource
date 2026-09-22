require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollectionsController, type: :controller do

  describe 'LinkedTeamsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::LinkedTeamsControllerBehavior)
    end
  end

  describe 'OrganizationCollectionsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::OrganizationCollectionsControllerBehavior)
    end
  end

  describe 'collection access' do
    let(:depositor)     { FactoryBot.create(:contributor) }
    let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

    before do
      sign_in user
      organization.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    end

    describe 'collection access' do
      let(:params)  { { id: organization.id } }

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :about, params: params
          expect(response.status).to eq(200)
          get :media_export, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_download_counts, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_downloads, params: params, format: :csv
          expect(response.status).to eq(200)
          get :media_requests, params: params, format: :csv
          expect(response.status).to eq(200)
        end
      end

      context 'user is not an admin' do
        let(:user)  { FactoryBot.create(:registered_user) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :about, params: params
          expect(response.status).to eq(200)
        end

        context 'user is a collection manager' do
          let(:user)  { depositor }

          before do
            organization.managers << user
            organization.managers_group.save
          end

          it 'responds with a 200' do
            get :media_export, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_download_counts, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_downloads, params: params, format: :csv
            expect(response.status).to eq(200)
            get :media_requests, params: params, format: :csv
            expect(response.status).to eq(200)
          end
        end

        context 'user is not a collection manager' do
          let(:user)  { FactoryBot.create(:contributor) }

          it 'responds with a 403' do
            get :media_export, params: params
            expect(response.status).to eq(403)
            get :media_download_counts, params: params
            expect(response.status).to eq(403)
            get :media_downloads, params: params, format: :csv
            expect(response.status).to eq(403)
            get :media_requests, params: params, format: :csv
            expect(response.status).to eq(403)
          end
        end
      end
    end
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'collection_type' do
    it {expect(subject.collection_type).to eq(Hyrax::CollectionType.find_by(Morphosource::CollectionTypes::Organizations::SETTINGS)) }
  end

  describe 'search_builder_class' do
    it {expect(subject.search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder) }
  end

  describe 'configure_facets' do
    let(:controller_instance) { described_class.new }
    let(:facet_fields) { controller_instance.blacklight_config.facet_fields }

    describe 'publication_status' do
      subject { facet_fields["publication_status"]}
      it 'has a publication_status facet' do
        expect(subject.label).to eq("Publication Status")
      end
    end

    describe 'media_type' do
      subject { facet_fields["media_type"]}
      it 'has a media_type facet' do
        expect(subject.label).to eq("Media Type")
      end
    end

    describe 'object' do
      subject { facet_fields["object"]}
      it 'has a object facet' do
        expect(subject.label).to eq("Object")
      end
    end

    describe 'taxonomy_name' do
      subject { facet_fields["taxonomy_name"]}
      it 'has a taxonomy_name facet' do
        expect(subject.label).to eq("Taxonomy (Name)")
      end
    end

    describe 'device' do
      subject { facet_fields["device"]}
      it 'has a device facet' do
        expect(subject.label).to eq("Device")
      end
    end

    describe 'device_organization' do
      subject { facet_fields["device_organization"]}
      it 'has a device_organization facet' do
        expect(subject.label).to eq("Device Organization")
      end
    end

    describe 'team' do
      subject { facet_fields["team"]}
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end

    describe 'project' do
      subject { facet_fields["project"] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end

    describe 'owner' do
      subject { facet_fields["owner"] }
      it 'has a owner facet' do
        expect(subject.label).to eq("Data Manager")
      end
    end

    describe 'depositor' do
      subject { facet_fields["depositor"] }
      it 'has a depositor facet' do
        expect(subject.label).to eq("Data Uploader")
      end
    end

    describe 'object type' do
      subject { facet_fields["object_type"] }
      it 'has an object type facet' do
        expect(subject.label).to eq("Object Type")
      end
    end

    describe 'transfer status' do
      subject { facet_fields["transfer"] }

      let(:organization)  { FactoryBot.create(:organization_collection, visibility: 'open', depositor: user.ms_id) }
      let(:user)          { FactoryBot.create(:admin) }

      context 'with admin user' do
        before do
          allow(controller_instance).to receive(:current_user) { user }
          controller_instance.instance_variable_set(:@curation_concern, organization)
          controller_instance.create_transfer_facet
        end

        it 'has a transfer status facet' do
          expect(subject.label).to eq("Transfer Status")
        end

        it 'has managed, transfer_pending, awaiting_publish, and unready query buckets' do
          expect(subject.query.keys).to match_array(%w[managed transfer_pending awaiting_publish unready])

          expect(subject.query["managed"][:label]).to eq("Managed by Organization")
          expect(subject.query["managed"][:fq]).to eq("owner_ssim:#{organization.id}")

          expect(subject.query["transfer_pending"][:label]).to eq("Transfer Request Pending")
          expect(subject.query["transfer_pending"][:fq]).to eq("-owner_ssim:#{organization.id} AND pending_org_transfer_bsi:true")

          expect(subject.query["awaiting_publish"][:label]).to eq("Will Generate Transfer Request on Publication")
          expect(subject.query["awaiting_publish"][:fq]).to eq("-owner_ssim:#{organization.id} AND organization_transfer_on_publish_bsi:true")

          expect(subject.query["unready"][:label]).to eq("Not Available for Automated Transfer")
          expect(subject.query["unready"][:fq]).to eq("-owner_ssim:#{organization.id} AND -pending_org_transfer_bsi:true AND -organization_transfer_on_publish_bsi:true")
        end
      end

      context 'with non-admin user' do
        let(:user)          { FactoryBot.create(:user) }

        before do
          allow(controller_instance).to receive(:current_user) { user }
          controller_instance.instance_variable_set(:@curation_concern, organization)
          controller_instance.create_transfer_facet
        end

        it 'has a transfer status facet' do
          expect(subject).to be nil
        end
      end
    end
  end

  describe 'search_action_url' do
    let(:organization)  { FactoryBot.create(:organization_collection, visibility: 'open', depositor: user.ms_id) }
    let(:user)          { FactoryBot.create(:admin) }

    before do
      subject.instance_variable_set(:@curation_concern, organization)
    end

    it 'is organization_path' do
      expect(subject.send(:search_action_url)).to eq("/organizations/#{organization.id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:organization)  { FactoryBot.create(:organization_collection, visibility: 'open', depositor: user.ms_id) }
    let(:user)          { FactoryBot.create(:admin) }
    let(:facet_id)      { 'depositor_ssim' }

    before do
      subject.instance_variable_set(:@collection, organization)
    end
    it 'is organization_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/organizations/#{organization.id}/facet/#{facet_id}?locale=en")
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end
end