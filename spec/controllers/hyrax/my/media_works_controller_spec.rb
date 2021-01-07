require 'rails_helper'

RSpec.describe Hyrax::My::MediaWorksController, type: :controller do
  let(:user) { User.create(email: 'email@email.com', password: 'password') }
  let(:admin_role)  { Role.create(name: 'admin') }

  before do
    admin_role.users << user
    admin_role.save
    sign_in user
    # skip all methods, just need to test which partial to be rendered
    allow(controller).to receive(:query_collection_information) { }
    allow(controller).to receive(:query_collection_members) { }
    allow(controller).to receive(:prepare_instance_variables_for_batch_control_display) { }
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
