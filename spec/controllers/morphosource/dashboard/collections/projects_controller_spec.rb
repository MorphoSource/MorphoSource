# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Dashboard::Collections::ProjectsController, type: :controller do

  let(:user)  { User.create(email: 'email@email.com', password: 'password')}
  let!(:contributors)  { Role.create(name: 'contributor') }
  let(:project)  { Collection.create(title: ['project'], collection_type_gid: project_collection_type.to_global_id, depositor: user.ms_id) }
  let(:media) { Media.create(title: ['media']) }
  let(:params)  { { "id" => project.id, "collection" => { "representative_id" => media.id } } }

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
end
