require 'rails_helper'

RSpec.describe Hyrax::UsersController, :type => :controller do
  let!(:current_user)   { User.create(email: "email@email.com", password: "password", display_name: "Bugs Bunny")}
  let!(:user1)          { User.create(email: "purple@email.com", password: "password", display_name: "Mickey Mouse") }
  let!(:user2)          { User.create(email: "blue@email.com", password: "password", display_name: "Donald Duck") }

  before do
    sign_in current_user
  end

  describe "query users" do
    routes { Hyrax::Engine.routes }

    it "finds the expected user via email" do
      get :index, params: { uq: "purple" }
      expect(assigns[:users]).to include(user1)
      expect(assigns[:users]).not_to include(user2, current_user)
      expect(response).to be_successful
    end

    context "by display name" do
      it "finds the expected user via display name" do
        get :index, params: { uq: "Mickey" }
        expect(assigns[:users]).to include(user1)
        expect(assigns[:users]).not_to include(user2, current_user)
        expect(response).to be_successful
      end
    end
  end
end
