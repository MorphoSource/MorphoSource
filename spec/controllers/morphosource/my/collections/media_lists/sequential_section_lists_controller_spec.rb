require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaLists::SequentialSectionListsController, type: :controller do

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
