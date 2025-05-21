require 'rails_helper'

RSpec.describe Morphosource::Admin::PagesController, type: :controller do
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  let(:valid_attributes1) { { slug: 'valid-slug1', title: 'Valid Title1', page_type: 'pages', visibility: 'published' } }
  let(:valid_attributes2) { { slug: 'valid-slug2', title: 'Valid Title2', page_type: 'pages', visibility: 'published' } }
  let!(:page1) { Page.create!(valid_attributes1) }
  let!(:page2) { Page.create!(valid_attributes2) }

  describe 'GET #index' do
    context 'when an admin user is signed in' do
      before { sign_in admin }

      it 'renders the index template and assigns @items' do
        get :index

        expect(response).to have_http_status(:success)
        expect(response).to render_template(:index)
        expect(assigns(:items)).to include(*[page1, page2])
      end
    end

    context 'when a normal user is signed in' do
      before { sign_in user }

      it 'redirects to the root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when no user is logged in' do
      it 'redirects to the root path' do
        get :index
        expect(response).to redirect_to(root_path)
      end
    end
  end
end