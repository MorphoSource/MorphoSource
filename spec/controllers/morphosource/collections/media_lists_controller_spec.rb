require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::MediaListsController, type: :controller do

  let(:user)                        { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor)                   { User.create(email: 'depositor@email.com', password: 'password') }
  let(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'Media List') }
  let(:media_list)                  { MediaList.create(title: ['media list'], collection_type_gid: media_list_collection_type.gid, depositor: depositor.ms_id) }

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::MediaListPresenter) }
  end

  describe 'search_action_url' do
    before do
      subject.instance_variable_set(:@curation_concern, media_list)
    end
    it 'is media_list_media_path' do
      expect(subject.send(:search_action_url)).to eq("/media_lists/#{media_list.id}?locale=en")
    end
  end

  describe 'search_facet_path' do
    let(:facet_id)  { 'depositor_ssi' }
    before do
      subject.instance_variable_set(:@collection, media_list)
    end
    it 'is media_list_media_path' do
      expect(subject.send(:search_facet_path, {id: facet_id})).to eq("/media_lists/#{media_list.id}/facet/#{facet_id}?locale=en")
    end
  end

  # helpers/morphosource/my/works_helper
  describe '#search_action_for_dashboard' do
    let(:main_app)    { Rails.application.routes.url_helpers }
    let(:params)      { { controller: controller.controller_path } }
    let(:collection)  { double('collection', id: 'abc')}
    subject           { controller.view_context }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, collection)
    end

    it { expect(subject.search_action_for_dashboard).to eq(main_app.media_list_media_path(id: collection.id, locale: 'en')) }
  end
end
