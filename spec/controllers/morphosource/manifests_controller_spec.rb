require 'rails_helper'

RSpec.describe Morphosource::ManifestsController, type: :controller do
  describe 'GET #show' do
    let(:user)  { create(:confirmed_user) }
    let(:private_media) { create(:media, depositor: user.ms_id ) }
    let(:public_media) { create(:public_media, depositor: user.ms_id ) }

    context 'when media is public' do
      it 'displays iiif manifest' do
        get :show, params: { id: public_media.access_control_id }

        expect(response).to have_http_status(200)
        expect(response.body).to include '@context'
      end
    end

    context 'when media is private' do
      it 'redirects to site root' do
        get :show, params: { id: private_media.access_control_id }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to '/'
      end
    end

    context 'when media is private but user has temporary access cookie' do
      let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )} 
      let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

      before do
        allow(subject).to receive(:cookies).and_return(cookie_jar)
      end

      it 'displays iiif manifest' do
        cookie_jar.encrypted[temporary_link.media_id] = { 
          value: temporary_link.token, 
          expires: temporary_link.expires_at
        }

        get :show, params: { id: private_media.access_control_id }

        expect(response).to have_http_status(200)
        expect(response.body).to include '@context'
      end
    end
  end
end