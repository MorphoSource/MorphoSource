# frozen_string_literal: true
require 'rails_helper'

RSpec.describe SequentialSectionList, type: :model do
  let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'List', machine_id: 'sequential_section_list') }

  describe 'collection_type' do
    it { expect(described_class.collection_type).to eq(sequential_section_list_collection_type) }
    it { expect(subject.collection_type).to eq(sequential_section_list_collection_type) }
  end

  describe 'presenter_class' do
    it { expect(subject.presenter_class).to eq(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'human_readable_type' do
    it { expect(subject.human_readable_type).to eq("Sequential Section List") }
  end
end
