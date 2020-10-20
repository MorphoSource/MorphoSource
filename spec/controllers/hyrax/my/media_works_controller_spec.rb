require 'rails_helper'

RSpec.describe Hyrax::My::MediaWorksController, type: :controller do
  let(:user) { User.create(email: 'email@email.com', password: 'password') }

  before do
    sign_in user
  end

  describe 'GET #index' do

    context 'not adding media to a collection' do
      it 'renders default template' do
        get :index
        expect(response).to render_template("hyrax/my/media_works/index")
      end
    end

    context 'adding media to a collection' do
      it 'renders the add to collection template' do
        get :index, params: { add_works_to_collection_label: "Test Project" }
        expect(response).to render_template("hyrax/my/media_works/index_add_to_collection")
      end
    end

  end


end
