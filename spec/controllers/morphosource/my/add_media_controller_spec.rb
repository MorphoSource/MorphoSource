require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::AddMediaController, type: :controller do
  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:project)                 { Collection.create(title: ['Project'], collection_type_gid: project_collection_type.gid, depositor: user.ms_id) }

  describe '#index' do
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

  describe 'search_action_url' do
    let(:collection_id) { "foobar" }
    it 'is add_media#index' do
      expect(controller.send(:search_action_url, [{"collection_id"=>collection_id}])).to eq( "/dashboard/my/media/collection_id=#{collection_id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:collection_id) { "foo" }
    let(:id) { "bar" }
    before do
      allow(controller).to receive(:params).and_return({"collection_id" => collection_id})
    end
    it 'is add_media#facet' do
      expect(controller.send(:search_facet_path, {:id => id})).to eq( "/dashboard/my/media/#{collection_id}/facet/#{id}?locale=en")
    end
  end

  describe 'search_action_url' do
    it 'is media#index' do
      expect(controller.send(:search_action_url, [])).to eq("/dashboard/my/media/?locale=en")
    end
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc')}
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.my_add_media_index_path(collection_id: collection.id, locale: 'en')) }
  end
end
