# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::ProjectsController, type: :controller do

  let(:user)                        { User.create(email: 'email@email.com', password: 'password')}
  let!(:contributors)               { Role.create(name: 'contributor') }
  let(:project)                     { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id, depositor: user.ms_id) }
  let!(:media_list_collection_type) { Hyrax::CollectionType.find_or_create_by(Morphosource::CollectionTypes::MediaLists::SETTINGS) }
  let(:media)                       { Media.create(title: ['media']) }
  let(:params)                      { { "id" => project.id, "collection" => { "representative_id" => media.id } } }

  before do
    contributors.users += [user]
    allow(user).to receive(:can?).with(:edit, project).and_return(true)
    sign_in user
    allow(subject).to receive(:current_user).and_return(user)
    project.create_collection_groups
    project.edit_users += [user]
    project.save
  end

  it 'should have TeamPresenter' do
    expect(controller.presenter_class).to be(Morphosource::Collections::ProjectPresenter)
  end

  describe '#update' do
    it 'calls update_thumbnail' do
      expect(subject).to receive(:update_thumbnail)
      put :update, params: params
    end
  end

  describe 'update_thumbnail' do
    let(:params)  { { id: project.id, collection: { representative_id: media.id } } }

    before do
      allow(subject).to receive(:params).and_return(params)
      subject.instance_variable_set(:@collection, project)
      subject.send(:update_thumbnail)
    end

    context 'user inputs a representative_id' do
      it 'sets the thumbnail id to the media thumbnail id' do
        expect(project.thumbnail_id).to eq(media.thumbnail_id)
      end
    end
    context 'user does not input a representative_id' do
      it 'sets the thumbnail id to nil' do
        expect(project.thumbnail_id).to eq(nil)
      end
    end
  end

  describe 'create_list' do
    let(:params)  { { id: project.id } }

    context 'when successful' do
      it 'creates a new media list from the project' do
        expect { get :create_list, params: params }.to change(MediaList, :count).by(1)
      end

      it 'redirects to the new media list' do
        get :create_list, params: params
        new_list = MediaList.last
        expect(response).to redirect_to(media_list_path(new_list))
        expect(flash[:notice]).to eq("New Media List successfully created from Project. Media are being copied in the background.")
      end
    end

    context 'when an error occurs' do
      before do
        allow_any_instance_of(Collection).to receive(:fork_to_list).with(user).and_raise(StandardError.new("Test error"))
      end

      it 'redirects to the project edit page with an error message' do
        get :create_list, params: params
        expect(response).to redirect_to(project_edit_path(project))
        expect(flash[:error]).to eq("There was an error forking the Project to a Media List: Test error")
      end
    end
  end
end
