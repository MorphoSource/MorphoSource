require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::BiologicalSpecimensController, type: :controller do
  let(:user)  { User.create(email: 'user@email.com', password: 'password') }

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'source' do
      subject { facet_fields['record_source_ssim']}
      it 'has a record source facet' do
        expect(subject.label).to eq("Source")
      end
    end
    describe 'organization' do
      subject { facet_fields['organization_ssim']}
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(10)
      end
    end
    describe 'project' do
      subject { facet_fields['media_member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['media_member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(10)
        expect(subject.helper_method).to eq(:collection_title_by_id)
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
      it 'renders the specimens page with the correct variables' do
        expect(response).to render_template("morphosource/my/works/index")
        expect(response.status).to eq(200)
        expect(subject.instance_variable_get(:@tab)).to eq(:specimens)
      end
    end
  end

  describe 'search_builder_class' do
    context 'user is an admin' do
      before do
        allow(controller).to receive_message_chain(:current_user, :admin?).and_return(true)
      end
      it { expect(controller.search_builder_class).to eq(Morphosource::Users::EditSpecimensSearchBuilder) }
    end
    context 'user is not an admin' do
      before do
        allow(controller).to receive_message_chain(:current_user, :admin?).and_return(false)
      end
      it { expect(controller.search_builder_class).to eq(Morphosource::Users::MySpecimensSearchBuilder) }
    end
  end

  describe 'search_facet_path' do
    let(:id) { "foobar" }

    it 'is biological_specimens#facet' do
      expect(controller.send(:search_facet_path, {:id => id})).to eq( "/dashboard/my/specimens/facet/#{id}?locale=en")
    end
  end

  describe 'search_action_url' do
    it 'is biological_specimens#index' do
      expect(controller.send(:search_action_url, [])).to eq("/dashboard/my/specimens?locale=en")
    end
  end
end
