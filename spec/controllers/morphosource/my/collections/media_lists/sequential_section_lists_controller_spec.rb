require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaLists::SequentialSectionListsController, type: :controller do

  let(:user)                                      { User.create(email: 'user@email.com', password: 'password') }
  let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List') }

  describe 'temporary admin-only restriction' do
    before do
      sign_in user
    end

    context 'user is an admin' do
      let(:admin_role)  { Role.create(name: 'admin') }
      before do
        admin_role.users << user
        admin_role.save
      end
      it 'responds with a 200' do
        get :index
        expect(response.status).to eq(200)
      end
    end

    context 'user is not an admin' do
      it 'responds with a redirect' do
        get :index
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'collections_type' do
    it { expect(subject.collections_type).to eq('sequential_section_lists') }
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to be(Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder) }
  end

  describe 'search_action_url' do
    it 'is media_list_media_path' do
      expect(subject.search_action_url).to include("/dashboard/my/sequential_section_lists?locale=en")
    end
  end

  describe 'search_action_for_dashboard' do
    it { expect(subject.search_action_for_dashboard).to eq("/dashboard/my/sequential_section_lists?locale=en") }
  end
end
