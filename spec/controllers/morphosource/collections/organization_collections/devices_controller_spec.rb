require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::OrganizationCollections::DevicesController, type: :controller do
  let(:main_app)      { Rails.application.routes.url_helpers }
  let(:depositor)     { User.create(email: 'depositor@email.com', password: 'password') }
  let!(:organization) { FactoryBot.create(:organization_collection, visibility: 'open', depositor: depositor.ms_id) }

  describe 'OrganizationCollectionsControllerBehavior' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::OrganizationCollectionsControllerBehavior)
    end
  end

  describe 'OrganizationHelper' do
    it 'is included' do
      expect(described_class.ancestors).to include(Morphosource::Collections::OrganizationCollectionHelper)
    end
  end

  describe 'collection access' do
    before do
      sign_in user
      Morphosource::Collections::PermissionsCreateService.create_default(collection: organization)
    end

    describe 'collection access' do
      let(:params)  { { id: organization.id } }

      context 'user is an admin' do
        let(:user) { FactoryBot.create(:admin) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
          get :devices_export, params: params, format: :csv
          expect(response.status).to eq(200)
        end
      end

      context 'user is not an admin' do
        let(:user)  { FactoryBot.create(:contributor) }

        it 'responds with a 200' do
          get :show, params: params
          expect(response.status).to eq(200)
        end

        context 'user is a collection editor' do
          let(:user)  { depositor }

          it 'responds with a 200' do
            get :devices_export, params: params, format: :csv
          expect(response.status).to eq(200)
          end
        end

        context 'user is not a collection editor' do
          let(:user)  { FactoryBot.create(:contributor) }

          it 'responds with a 403' do
            get :devices_export, params: params, format: :csv
          expect(response.status).to eq(403)
          end
        end
      end
    end
  end

  describe 'search_builder_class' do
    it {expect(subject.search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::DevicesSearchBuilder) }
  end

  describe 'media_count_search_builder_class' do
    it {expect(subject.media_count_search_builder_class).to eq(Morphosource::Collections::OrganizationCollections::OrganizationMediaSearchBuilder) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::OrganizationPresenter) }
  end

  describe 'search_action_url' do
    let(:user) { FactoryBot.create(:admin) }

    before do
      subject.instance_variable_set(:@collection, organization)
    end
    it 'is organization_devices_path' do
      expect(subject.send(:search_action_url)).to eq("/organizations/#{organization.id}/devices?locale=en")
    end
  end

  describe 'configure_facets' do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}

    before do
      described_class.configure_facets
    end

    describe 'manufacturer' do
      subject { facet_fields["manufacturer"]}
      it 'has a manufacturer facet' do
        expect(subject.label).to eq("Manufacturer")
      end
    end

    describe 'model' do
      subject { facet_fields["model"] }
      it 'has a model facet' do
        expect(subject.label).to eq("Model")
      end
    end

    describe 'modality' do
      subject { facet_fields["modality"] }
      it 'has a modality facet' do
        expect(subject.label).to eq("Modality")
      end
    end
  end

  describe 'search_facet_path' do
    let(:user) { FactoryBot.create(:admin) }

    let(:facet_id)  { 'depositor_ssim' }
    before do
      subject.instance_variable_set(:@collection, organization)
    end
    it 'is device_facet_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/organizations/#{organization.id}/devices/facet/#{facet_id}?locale=en")
    end
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:devices) }
  end

  describe '#search_action_for_dashboard' do
    before do
      subject.instance_variable_set(:@collection, organization)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.organization_devices_path(organization, locale: 'en')) }
  end
end