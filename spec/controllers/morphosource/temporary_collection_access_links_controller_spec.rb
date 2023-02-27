require 'rails_helper'

RSpec.describe Morphosource::Admin::TemporaryCollectionAccessLinksController, :type => :controller do
  let(:manager_user)  { create(:confirmed_user) }
  let(:other_manager_user)  { create(:confirmed_user) }
  let(:public_user) { create(:confirmed_user) }
  let(:project) { create(:project, depositor: manager_user.ms_id ) }
  let(:params) { { collection_id: project.id, expires_at: Time.zone.now + 1.month } }

  describe 'POST #create' do
    context 'when params are not provided' do
      it 'temporary access link is not created and response is error' do
        expect{
        process :create, method: :post
        }.to raise_error(ActionController::UrlGenerationError)
      end 
    end

    context 'when user is manager for project and can create temporary access links' do
      before do 
        project.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
        project.managers_group.users << manager_user
        project.managers_group.save
        project.save
        allow(controller).to receive(:current_user) { manager_user }
      end

      it 'temporary access link is created and page is redirected' do
        expect{
          process :create, method: :post, params: params
        }.to change{TemporaryCollectionAccessLink.count}.by(1)

        expect(response).to redirect_to(collection_edit_path(project.id))
      end 
    end

    context 'when user is not manager for project and cannot create temporary access links' do
      before do 
        allow(controller).to receive(:current_user) { public_user }
      end

      it 'temporary access link is not created and response is error' do
        expect{
        process :create, method: :post, params: params
        }.to change{TemporaryCollectionAccessLink.count}.by 0

        expect(response).to have_http_status 401
      end 
    end
  end

  describe 'POST #destroy' do
    let!(:temporary_link) { create(:temporary_collection_access_link, user: other_manager_user, collection_id: project.id )} 
    context 'when params are not provided' do
      it 'temporary access link is not created and response is error' do
        expect{
        process :destroy, method: :delete
        }.to raise_error(ActionController::UrlGenerationError)
      end 
    end

    context 'user created temp link and is able to delete temporary collection access link' do
      before do
        sign_in other_manager_user
      end

      it 'temporary access link is deleted and page is redirected' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryCollectionAccessLink.count}.by(-1)
  
        expect(response).to redirect_to(collection_edit_path(project.id))
      end 
    end

    context 'user did not create link but is collection manager and is able to delete temporary collection access link' do
      before do
        project.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
        project.managers_group.users << manager_user
        project.managers_group.save
        project.save
        sign_in manager_user
      end

      it 'temporary access link is deleted and page is redirected' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryCollectionAccessLink.count}.by(-1)
  
        expect(response).to redirect_to(collection_edit_path(project.id))
      end 
    end

    context 'user is not able to delete temporary collection access link' do
      before do
        project.create_collection_groups
        Morphosource::Collections::PermissionsCreateService.create_default(collection: project)
        sign_in public_user
        project.save
      end

      it 'temporary access link is not deleted and page is redirected' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryCollectionAccessLink.count}.by(0)
  
        expect(response).to have_http_status 401
      end 
    end
  end
end