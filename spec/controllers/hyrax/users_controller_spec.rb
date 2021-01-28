require 'rails_helper'

RSpec.describe Hyrax::UsersController, :type => :controller do
  routes { Hyrax::Engine.routes }

  describe "query users" do
    let!(:current_user)   { User.create(email: "email@email.com", password: "password", display_name: "Bugs Bunny")}
    let!(:user1)          { User.create(email: "purple@email.com", password: "password", display_name: "Mickey Mouse") }
    let!(:user2)          { User.create(email: "blue@email.com", password: "password", display_name: "Donald Duck") }

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
