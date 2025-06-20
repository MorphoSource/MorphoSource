require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  let(:valid_attributes) { { slug: 'valid-slug', title: 'Valid Title', page_type: 'pages', visibility: 'published' } }
  let(:invalid_attributes) { { slug: '', title: '', page_type: 'pages', visibility: 'published' } }
  let(:page) { Page.create!(valid_attributes) }
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  describe 'GET #show' do
    context 'when the page is published' do
      it 'renders the show template' do
        get :show, params: { slug: page.slug }
        expect(response).to render_template(:show)
        expect(assigns(:page)).to eq(page)
      end
    end

    context 'when the page is unpublished' do
      before { page.update!(visibility: 'unpublished') }

      context 'and user is not logged in' do
        it 'redirects to the root path' do
          get :show, params: { slug: page.slug }
          expect(response).to redirect_to(root_path)
        end
      end

      context 'and user is logged in' do
        before { sign_in user }

        it 'redirects to root path' do
          get :show, params: { slug: page.slug }
          expect(response).to redirect_to(root_path)
        end
      end

      context 'and user is an admin' do
        before { sign_in admin }

        it 'renders the show template' do
          get :show, params: { slug: page.slug }
          expect(response).to render_template(:show)
          expect(assigns(:page)).to eq(page)
        end
      end
    end

    context 'when the page is a doc but the page_type param is missing' do
      before { page.update!(page_type: 'docs') }

      it 'redirects to the docs path' do
        get :show, params: { slug: page.slug }
        expect(response).to redirect_to(docs_path(page))
      end
    end
  end

  context 'admin protected routes' do
    before { sign_in admin }

    describe 'GET #new' do
      it 'assigns a new page' do
        get :new
        expect(assigns(:page)).to be_a_new(Page)
      end
    end

    describe 'POST #create' do
      context 'with valid attributes' do
        it 'creates a new page and redirects to it' do
          expect {
            post :create, params: { page: valid_attributes }
          }.to change(Page, :count).by(1)
          expect(response).to redirect_to(Page.last)
          expect(flash[:notice]).to eq('Page was successfully created.')
        end
      end

      context 'with invalid attributes' do
        it 'does not create a new page and re-renders the new template' do
          expect {
            post :create, params: { page: invalid_attributes }
          }.not_to change(Page, :count)
          expect(response).to render_template(:new)
          expect(flash[:alert]).to be_present
        end
      end
    end

    describe 'GET #edit' do
      it 'assigns the requested page' do
        get :edit, params: { slug: page.slug }
        expect(assigns(:page)).to eq(page)
      end
    end

    describe 'PATCH/PUT #update' do
      context 'with valid attributes' do
        it 'updates the page and redirects to it' do
          patch :update, params: { slug: page.slug, page: { title: 'Updated Title' } }
          page.reload
          expect(page.title).to eq('Updated Title')
          expect(response).to redirect_to(page)
          expect(flash[:notice]).to eq('Page was successfully updated.')
        end
      end

      context 'with invalid attributes' do
        it 'does not update the page and re-renders the edit template' do
          patch :update, params: { slug: page.slug, page: { title: '' } }
          page.reload
          expect(page.title).not_to eq('')
          expect(response).to render_template(:edit)
          expect(flash[:alert]).to be_present
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested page and redirects to admin_pages_path' do
        page
        expect {
          delete :destroy, params: { slug: page.slug }
        }.to change(Page, :count).by(-1)
        expect(response).to redirect_to(admin_pages_path)
        expect(flash[:notice]).to eq('Page was successfully destroyed.')
      end
    end
  end

  context 'admin protected routes when user is a normal user' do
    before { sign_in user }
  
    describe 'GET #new' do
      it 'redirects to the root path' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'POST #create' do
      it 'does not create a new page and redirects to the root path' do
        expect {
          post :create, params: { page: valid_attributes }
        }.not_to change(Page, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'GET #edit' do
      it 'redirects to the root path' do
        get :edit, params: { slug: page.slug }
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'PATCH/PUT #update' do
      it 'does not update the page and redirects to the root path' do
        patch :update, params: { slug: page.slug, page: { title: 'Updated Title' } }
        page.reload
        expect(page.title).not_to eq('Updated Title')
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'DELETE #destroy' do
      it 'does not destroy the page and redirects to the root path' do
        page
        expect {
          delete :destroy, params: { slug: page.slug }
        }.not_to change(Page, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  context 'admin protected routes when no user is logged in' do
    describe 'GET #new' do
      it 'redirects to the root path' do
        get :new
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'POST #create' do
      it 'does not create a new page and redirects to the root path' do
        expect {
          post :create, params: { page: valid_attributes }
        }.not_to change(Page, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'GET #edit' do
      it 'redirects to the root path' do
        get :edit, params: { slug: page.slug }
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'PATCH/PUT #update' do
      it 'does not update the page and redirects to the root path' do
        patch :update, params: { slug: page.slug, page: { title: 'Updated Title' } }
        page.reload
        expect(page.title).not_to eq('Updated Title')
        expect(response).to redirect_to(root_path)
      end
    end
  
    describe 'DELETE #destroy' do
      it 'does not destroy the page and redirects to the root path' do
        page
        expect {
          delete :destroy, params: { slug: page.slug }
        }.not_to change(Page, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
