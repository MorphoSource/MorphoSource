require 'rails_helper'

RSpec.describe Hyrax::MediaTemporaryLinkViewController, type: :controller do
  # describe "search_builder_class" do
  #   it "is Morphosource::TemporaryMediaAccessLinkSearchBuilder" do
  #     expect(subject.send(:search_builder_class)).to be(Morphosource::TemporaryMediaAccessLinkSearchBuilder)
  #   end
  # end

  describe 'GET #showcase' do
    let(:user)  { create(:confirmed_user) }
    let(:media) { create(:media, depositor: user.ms_id ) }

    # context 'when params are not provided' do
    #   it 'a url generation error is produced' do
    #     expect{
    #       process :showcase, method: :get
    #     }.to raise_error(ActionController::UrlGenerationError)
    #   end
    # end

    context 'when accessed with valid temporary link credentials' do
      let!(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: media.id )} 
      let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

      before do
        allow(subject).to receive(:cookies).and_return(cookie_jar)
      end

      it 'displays the media show page' do
        get :showcase, params: { id: media.id, token: temporary_link.token }
        expect(response.status).to eq(200)
      end

      it 'sets authorization cookie' do
        get :showcase, params: { id: media.id, token: temporary_link.token }
        expect(cookie_jar.encrypted[media.id].present?).to be true
      end
    end

    context 'when accessed without valid temporary link credentials for non-logged in user' do
      let(:main_app) { Rails.application.routes.url_helpers }
      
      it 'redirects to sign in' do
        get :showcase, params: { id: media.id, token: '1111' }
        expect(response.status).to eq(302)
        expect(response).to redirect_to main_app.new_user_session_path(locale: 'en')
      end
    end

    context 'when accessed without valid temporary link credentials for logged in user' do
      let(:main_app) { Rails.application.routes.url_helpers }
      
      it 'returns unauthorized' do
        sign_in user
        get :showcase, params: { id: media.id, token: '1111' }
        expect(response.status).to eq(401)
      end
    end
  end
end