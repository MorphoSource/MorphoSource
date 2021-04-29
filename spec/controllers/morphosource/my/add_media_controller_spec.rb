require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::AddMediaController, type: :controller do
  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

  context 'user is not signed in' do
    before do
      get :index, params: { collection_id: project.id }
    end
    it 'redirects' do
      expect(response.status).to eq(302)
    end
  end

  context 'collection does not exist' do
    before do
      sign_in user
      get :index, params: { collection_id: 'nope' }
    end
    it 'redirects to root' do
      expect(response.status).to eq(302)
    end
  end

  context 'user is not authorized to edit the collection' do
    before do
      sign_in user
      get :index, params: { collection_id: project.id }
    end
    it 'is unauthorized' do
      expect(response.status).to eq(401)
    end
  end

  context 'user is authorized to edit the collection' do
    before do
      project.create_collection_groups
      Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
      sign_in user
      get :index, params: { collection_id: project.id }
    end
    it 'renders the media page with the correct variables' do
      expect(response).to render_template("morphosource/my/works/index")
      expect(response.status).to eq(200)
      expect(subject.instance_variable_get(:@collection)).to eq(project)
      expect(subject.instance_variable_get(:@tab)).to eq(:add_media)
      expect(subject.instance_variable_get(:@page_title)).to eq("Select existing media to include in #{project.title.first}")
      expect(subject.instance_variable_get(:@add_to_collection_button_label)).to eq("Add media to #{project.title.first}")
    end
  end
end
