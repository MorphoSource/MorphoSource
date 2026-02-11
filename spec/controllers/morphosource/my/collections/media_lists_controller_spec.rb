require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaListsController, type: :controller do

  let!(:collection_type)  { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS) }
  let(:user)              { User.create(email: 'user@email.com', password: 'password') }

  describe 'registered user' do
    context 'user is sign in' do
      before do
        sign_in user
      end
      it 'responds with a 200' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'user is not signed in' do
      it 'responds with a redirect' do
        get :index
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'collections_type' do
    it { expect(subject.collections_type).to eq('media_lists') }
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to be(Morphosource::My::Collections::MediaListsSearchBuilder) }
  end

  describe 'search_action_url' do
    it 'is media_list_path' do
      expect(subject.search_action_url).to include(my_media_lists_path)
    end
  end

  describe 'search_action_for_dashboard' do
    it { expect(subject.search_action_for_dashboard).to eq(my_media_lists_path) }
  end

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['date_modified_dtsi asc',
       'date_modified_dtsi desc',
       'date_uploaded_dtsi asc',
       'date_uploaded_dtsi desc',
       'list_type_ssim asc',
       'list_type_ssim desc',
       'publication_status_si asc',
       'publication_status_si desc',
       'title_ssi asc',
       'title_ssi desc']
    end

    it 'includes custom sort parameters' do
      expect(subject.allowed_sort_parameters).to match_array(allowed_sort_params)
    end
  end
end
