require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::MediaController, type: :controller do
  let(:user)  { User.create(email: 'user@email.com', password: 'password') }

  describe ".configure_facets" do
    let(:facet_fields)  { described_class.blacklight_config.facet_fields}
    before do
      allow_any_instance_of(described_class).to receive(:search_builder_class).and_return("search_builder_class")
      described_class.configure_facets
    end
    describe 'publicaton status' do
      subject { facet_fields['publication_status_ssi']}
      it 'has a publication status facet' do
        expect(subject.label).to eq("Publication Status")
      end
    end
    describe 'media type' do
      subject { facet_fields['human_readable_media_type_ssim']}
      it 'has a media type facet' do
        expect(subject.label).to eq("Media Type")
      end
    end
    describe 'organization' do
      subject { facet_fields['media_organization_ssim'] }
      it 'has an organization facet' do
        expect(subject.label).to eq("Organization")
        expect(subject.limit).to eq(nil)
      end
    end
    describe 'project' do
      subject { facet_fields['member_of_project_ids_ssim'] }
      it 'has a project facet' do
        expect(subject.label).to eq("Project")
        expect(subject.limit).to eq(nil)
        expect(subject.helper_method).to eq(:collection_title_by_id)
      end
    end
    describe 'team' do
      subject { facet_fields['member_of_team_ids_ssim'] }
      it 'has a team facet' do
        expect(subject.label).to eq("Team")
        expect(subject.limit).to eq(nil)
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
      it 'sets the facet limit to nil' do
        facet_limits = subject.instance_variable_get(:@blacklight_config).facet_fields.each_with_object([]){|(k,v),limits| limits << v.limit}
        expect(facet_limits.uniq).to match_array([999999])
      end
      it 'renders the media page with the correct variables' do
        expect(response).to render_template("morphosource/my/works/index")
        expect(response.status).to eq(200)
        expect(subject.instance_variable_get(:@tab)).to eq(:media)
      end
    end

    context 'user is an admin' do
      let(:admins)  { Role.create(name: 'admin') }
      before do
        admins.users += [user]
        user.save!
        sign_in user
        get :index
      end
      it 'sets the individual facet limits to 15' do
        facet_limits = subject.instance_variable_get(:@blacklight_config).facet_fields.each_with_object([]){|(k,v),limits| limits << v.limit}
        expect(facet_limits.uniq).to match_array([15])
      end
    end
  end

  describe 'search_builder_class' do
    context 'user is an admin' do
      before do
        allow(controller).to receive_message_chain(:current_user, :admin?).and_return(true)
      end
      it { expect(controller.search_builder_class).to eq(Morphosource::Users::EditMediaSearchBuilder) }
    end
    context 'user is not an admin' do
      before do
        allow(controller).to receive_message_chain(:current_user, :admin?).and_return(false)
      end
      it { expect(controller.search_builder_class).to eq(Morphosource::Users::MyMediaSearchBuilder) }
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

  describe 'filtered_facets' do
    it 'lists facets to be filtered by access' do
      expect(controller.send(:filtered_facets)).to match_array(["member_of_project_ids_ssim", "member_of_team_ids_ssim"])
    end
  end
end
