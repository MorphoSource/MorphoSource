# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::MediaListsController, type: :controller do

  describe 'presenter_class' do
    it { expect(controller.presenter_class).to be(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'default_collection_type' do
    let!(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'Media List') }

    it { expect(subject.send(:default_collection_type).title).to eq("Media List") }
  end

  describe 'collection_class' do
    it { expect(subject.send(:collection_class)).to eq(MediaList) }
  end
end
