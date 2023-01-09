require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::MediaLists::SequentialSectionListsController, type: :controller do

  let(:user)                                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                               { User.create(email: 'depositor@email.com', password: 'password') }
  let(:sequential_section_list_collection_type) { Hyrax::CollectionType.create(title: 'Sequential Section List') }
  let(:sequential_section_list)                 { SequentialSectionList.create(title: ['sequential Section list'], collection_type_gid: sequential_section_list_collection_type.gid, depositor: depositor.ms_id) }

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'search_action_url' do
    before do
      subject.instance_variable_set(:@curation_concern, sequential_section_list)
    end
    it 'is sequential_section_list_media_path' do
      expect(subject.send(:search_action_url)).to eq("/sequential_section_lists/#{sequential_section_list.id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:facet_id)  { 'depositor_ssi' }
    before do
      subject.instance_variable_set(:@collection, sequential_section_list)
    end
    it 'is sequential_section_list_media_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/sequential_section_lists/#{sequential_section_list.id}/facet/#{facet_id}?locale=en")
    end
  end
end
