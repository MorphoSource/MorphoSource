require 'rails_helper'
require 'spec_helper'

RSpec.describe Morphosource::Collections::ProjectsController, type: :controller do

  let(:user)                    { User.create(email: 'user@email.com', password: 'password') }
  let(:depositor) { User.create(email: 'depositor@email.com', password: 'password') }
  let(:project_collection_type) { Hyrax::CollectionType.create(title: 'Project') }
  let(:project)                 { Collection.create(title: ['project'], collection_type_gid: project_collection_type.gid, depositor: depositor.ms_id) }

  before do
    project.create_collection_groups
  end

  describe "search_builder_class" do
    it{ expect(subject.search_builder_class).to eq(Morphosource::Collections::MediaSearchBuilder) }
  end

  describe 'tab' do
    it {expect(subject.send(:tab)).to eq(:media) }
  end

  describe 'presenter_class' do
    it {expect(subject.presenter_class).to eq(Morphosource::Collections::ProjectPresenter) }
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

    it { expect(subject.search_action_for_dashboard).to eq(main_app.project_media_path(id: collection.id, locale: 'en')) }
  end
end
