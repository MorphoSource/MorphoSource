require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::MediaController, type: :controller do

  let(:user)  { User.create(email: 'user@email.com', password: 'password') }

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      described_class.configure_facets
    end
    describe 'media type' do
      subject { facet_fields["media_type"]}
      it 'has a media type facet' do
        expect(subject.label).to eq("Media Type")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'object' do
      subject { facet_fields["object"] }
      it 'has an object facet' do
        expect(subject.label).to eq("Object")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'organization' do
      subject { facet_fields["organization"] }
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'publicaton status' do
      subject { facet_fields["publication_status"]}
      it 'has a publication status facet' do
        expect(subject.label).to eq("Publication Status")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'taxonomy name' do
      subject { facet_fields["taxonomy_name"]}
      it 'has a taxonomy name facet' do
        expect(subject.label).to eq("Taxonomy (Name)")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'team' do
      subject { facet_fields["team"] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'project' do
      subject { facet_fields["project"] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'owner' do
      subject { facet_fields["owner"]}
      it 'has a data manager facet' do
        expect(subject.label).to eq("Data Manager")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'depositor' do
      subject { facet_fields["depositor"]}
      it 'has a data uploader facet' do
        expect(subject.label).to eq("Data Uploader")
        expect(subject.limit).to eq(10)
      end
    end
  end

  describe '#index' do
    context 'user is not signed in' do
      before do
        get :index
      end
      it 'redirects' do
        expect(response.status).to eq(302)
      end
    end

    context 'user is signed in' do
      before do
        sign_in user
        get :index
      end
      it 'renders the media page with the correct variables' do
        expect(response).to render_template("morphosource/my/works/index")
        expect(response.status).to eq(200)
        expect(subject.instance_variable_get(:@tab)).to eq(:media)
      end
    end
  end

  describe 'search_builder_class' do
    context 'user is an admin' do
      let(:admins)  { Role.create(name: 'admin') }

      before do
        admins.users << user
        admins.save
        sign_in user
        get :index
      end
      
      it 'search_builder_class is EditSpecimensSearchBuilder' do
        expect(controller.blacklight_config.search_builder_class).to eq(Morphosource::Users::EditMediaSearchBuilder)
      end
    end

    context 'user is not an admin' do
      before do
        sign_in user
        get :index
      end

      it 'search_builder_class is MySpecimensSearchBuilder' do
        expect(controller.blacklight_config.search_builder_class).to eq(Morphosource::Users::MyMediaSearchBuilder)
      end
    end
  end

  describe 'search_facet_path' do
    let(:id) { "foobar" }

    it 'is media#facet' do
      expect(controller.send(:search_facet_path, {:id => id})).to eq( "/dashboard/my/media/facet/#{id}?locale=en")
    end
  end

  describe 'search_action_url' do
    it 'is media#index' do
      expect(controller.send(:search_action_url, [])).to eq("/dashboard/my/media?locale=en")
    end
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)  { Rails.application.routes.url_helpers }
    let(:params)    { { controller: controller.controller_path } }
    subject         { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.my_media_index_path(locale: 'en')) }
  end
end
