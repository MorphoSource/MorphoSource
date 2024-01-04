require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe Hyrax::UsersController, :type => :controller do
  context 'Hyrax route' do
    routes { Hyrax::Engine.routes }

    describe "query users" do
      

      let!(:current_user)   { User.create(email: "email@email.com", password: "password", first_name: "Bugs", last_name: "Bunny")}
      let!(:user1)          { User.create(email: "purple@email.com", password: "password", first_name: "Mickey", last_name: "Mouse")}
      let!(:user2)          { User.create(email: "blue@email.com", password: "password", first_name: "Donald", last_name: "Duck")}

      before do
        sign_in current_user
      end

      it "finds the expected user via email" do
        get :index, params: { format: 'json', uq: "purple" }

        expect(assigns[:users]).to include(user1)
        expect(assigns[:users]).not_to include(user2, current_user)
        expect(response).to be_successful
      end

      context "by display name" do
        it "finds the expected user via display name" do
          get :index, params: { format: 'json', uq: "Mickey" }

          expect(assigns[:users]).to include(user1)
          expect(assigns[:users]).not_to include(user2, current_user)
          expect(response).to be_successful
        end
      end
    end

    describe 'access permissions' do
      let(:admin)   { User.create(email: 'admin@email.com', password: 'password') }
      let(:user)    { User.create(email: 'user@email.com', password: 'password') }
      let(:admins)  { Role.create(name: 'admin') }

      describe '#index' do
        context 'user is an admin' do
          before do
            admins.users << admin
            admins.save
            sign_in admin
          end
          it 'is authorized' do
            get :index
            expect(response.status).to eq(200)
          end
        end
        context 'user is not an admin' do
          before do
            sign_in user
          end
          it 'redirects to the homepage' do
            get :index
            expect(response.status).to eq(302)
          end
        end
      end

      describe '#show' do
        context 'user is an admin' do
          before do
            sign_in admin
          end
          it 'is authorized' do
            get :show, params: { id: admin.ms_id }
            expect(response.status).to eq(200)
          end
        end
        context 'user is not an admin' do
          before do
            sign_in user
          end
          it 'is authorized' do
            get :show, params: { id: user.ms_id }
            expect(response.status).to eq(200)
          end
        end
        context 'user is not signed in' do
          it 'it redirects' do
            get :show, params: { id: user.ms_id }
            expect(response.status).to eq(302)
          end
        end
      end
    end
  end

  describe '#become' do
    let(:user) { FactoryBot.create(:user) }
    let(:user_to_become) { FactoryBot.create(:user) }
    let(:admin) { FactoryBot.create(:admin) } 

    context 'when no user is logged in' do
      it 'returns 404 not found' do
        get :become, params: { id: user.ms_id }
        expect(response.code).to eq("404")
      end
    end

    context 'when non-admin user is logged in' do
      before do 
        allow(controller).to receive(:current_user) { user }
      end

      it 'returns 404 not found' do
        get :become, params: { id: user.ms_id }
        expect(response.code).to eq("404")
      end
    end

    context 'when admin is logged in' do
      before do 
        sign_in admin
      end

      it 'returns 302 redirect to page root after signing in user' do
        get :become, params: { id: user.ms_id }
        expect(response.code).to eq("302")
        expect(response).to redirect_to root_path
        expect(response.flash[:notice]).to eq("Signed in as user #{user.name}.")
      end
    end
  end
end
