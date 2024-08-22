require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaLists::SequentialSectionListsController, type: :controller do

  let(:user)                                      { User.create(email: 'user@email.com', password: 'password') }

  describe 'collections_type' do
    it { expect(subject.collections_type).to eq('sequential_section_lists') }
  end

  describe 'search_builder_class' do
    it { expect(subject.search_builder_class).to be(Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder) }
  end

  describe 'search_action_url' do
    it { expect(subject.search_action_url).to include(my_sequential_section_lists_path) }
  end

  describe 'search_action_for_dashboard' do
    it { expect(subject.search_action_for_dashboard).to eq(my_sequential_section_lists_path) }
  end
end
