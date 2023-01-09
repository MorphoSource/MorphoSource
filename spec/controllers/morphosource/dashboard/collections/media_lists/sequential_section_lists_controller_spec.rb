# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaLists::SequentialSectionListsController, type: :controller do
  include SingleValuedForm

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaLists::SequentialSectionListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Sequential Section List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(SequentialSectionList) }
  end
end
