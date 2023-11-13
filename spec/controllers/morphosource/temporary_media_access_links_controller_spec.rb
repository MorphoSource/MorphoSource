require 'rails_helper'

RSpec.describe Morphosource::Admin::TemporaryMediaAccessLinksController, :type => :controller do
  let(:manager_user)  { create(:confirmed_user) }
  let(:other_manager_user)  { create(:confirmed_user) }
  let(:public_user) { create(:confirmed_user) }
  let(:media) { create(:media, depositor: manager_user.ms_id ) }
  let(:params) { { media_id: media.id, expires_at: Time.zone.now + 1.month } }

  describe 'POST #create' do
    context 'when params are not provided' do
      it 'temporary access link is not created and response is error' do
        expect{
        process :create, method: :post
        }.to raise_error(ActionController::UrlGenerationError)
      end 
    end

    context 'when user is data manager for media and can create temporary access links' do
      before do 
        allow(controller).to receive(:current_user) { manager_user }
        media.edit_users = media.edit_users + [manager_user]
        media.save!
      end

      it 'temporary access link is created and page is redirected' do
        expect{
          process :create, method: :post, params: params
        }.to change{TemporaryMediaAccessLink.count}.by(1)
 
        expect(response).to redirect_to(media_showcase_edit_path(media, anchor: 'share'))
      end 
    end

    context 'when user is not data manager but has edit access to media and can create temporary access links' do
      before do 
        allow(controller).to receive(:current_user) { other_manager_user }
        media.edit_users = media.edit_users + [other_manager_user]
        media.save!
      end

      it 'temporary access link is created and page is redirected' do
        expect{
          process :create, method: :post, params: params
        }.to change{TemporaryMediaAccessLink.count}.by(1)
 
        expect(response).to redirect_to(media_showcase_edit_path(media, anchor: 'share'))
      end 
    end

    context 'when user is not data manager for media and cannot create temporary access links' do
      let(:main_app) { Rails.application.routes.url_helpers }

      before do 
        allow(controller).to receive(:current_user) { public_user }
      end

      it 'temporary access link is not created and response redirects to site root with not found or unavailable flash' do
        expect{
        process :create, method: :post, params: params
        }.to change{TemporaryMediaAccessLink.count}.by 0

        expect(response).to have_http_status 302
        expect(response).to redirect_to main_app.root_path(locale: 'en')
      end 
    end
  end

  describe 'POST #destroy' do
    let!(:temporary_link) { create(:temporary_media_access_link, user: other_manager_user, media_id: media.id )} 
    context 'when params are not provided' do
      it 'temporary access link is not created and response is error' do
        expect{
        process :destroy, method: :delete
        }.to raise_error(ActionController::UrlGenerationError)
      end 
    end

    context 'user created temp link and is able to delete temporary media access link' do
      before do
        sign_in other_manager_user
      end

      it 'temporary access link is deleted and page is redirected' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryMediaAccessLink.count}.by(-1)
  
        expect(response).to redirect_to(media_showcase_edit_path(media, anchor: 'share'))
      end 
    end

    context 'user did not create link but is media data manager and is able to delete temporary media access link' do
      before do
        sign_in manager_user
      end

      it 'temporary access link is deleted and page is redirected' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryMediaAccessLink.count}.by(-1)
  
        expect(response).to redirect_to(media_showcase_edit_path(media, anchor: 'share'))
      end 
    end

    context 'user is not able to delete temporary media access link' do
      let(:main_app) { Rails.application.routes.url_helpers }
      
      before do
        sign_in public_user
      end

      it 'temporary access link is not deleted and page is redirected to site root with not found or unavailable flash' do
        expect{
          process :destroy, method: :delete, params: { id: temporary_link.id } 
        }.to change{TemporaryMediaAccessLink.count}.by(0)
  
        expect(response).to have_http_status 302
        expect(response).to redirect_to main_app.root_path(locale: 'en')
      end 
    end
  end
end