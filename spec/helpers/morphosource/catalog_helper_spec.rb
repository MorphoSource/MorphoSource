require 'rails_helper'

RSpec.describe Morphosource::CatalogHelper, type: :helper do
  include Rails.application.routes.url_helpers

  describe 'catalog_search_path' do
    before do
      allow(helper).to receive(:controller_name).and_return(cat_controller.controller_name)
    end
    context 'media catalog controller' do
      let(:cat_controller) { MediaCatalogController.new() }

      it 'returns the media search path' do
        expect(helper.catalog_search_path).to eq( main_app.media_search_path)
      end
    end

    context 'organization catalog controller' do
      let(:cat_controller) { OrganizationsCatalogController.new() }

      it 'returns the organization search path' do
        expect(helper.catalog_search_path).to eq( main_app.organization_search_path)
      end
    end

    context 'object catalog controller' do
      let(:cat_controller) { ObjectsCatalogController.new() }

      it 'returns the object search path' do
        expect(helper.catalog_search_path).to eq( main_app.object_search_path)
      end
    end

    context 'collection catalog controller' do
      let(:cat_controller) { CollectionsCatalogController.new() }

      it 'returns the collection search path' do
        expect(helper.catalog_search_path).to eq( main_app.collection_search_path)
      end
    end

    context 'all catalog controller' do
      let(:cat_controller) { AllCatalogController.new() }

      it 'returns the all search path' do
        expect(helper.catalog_search_path).to eq( main_app.all_search_path)
      end
    end
  end
end
