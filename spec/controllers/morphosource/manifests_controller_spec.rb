require 'rails_helper'

RSpec.describe Morphosource::ManifestsController, type: :controller do
  describe 'GET #show' do
    let(:main_app) { Rails.application.routes.url_helpers }
    let(:user)  { create(:confirmed_user) }
    let(:private_media) { create(:media, depositor: user.ms_id ) }
    let(:public_media) { create(:public_media, depositor: user.ms_id ) }

    context 'when media is public' do
      it 'displays iiif manifest in HTML when request is standard' do
        get :show, params: { id: public_media.access_control_id }

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('text/html')
        expect(response.body).to include '@context'
      end

      it 'displays iiif manifest in JSON when request is JSON' do
        get :show, params: { id: public_media.access_control_id }, format: :json

        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(response.body).to include '@context'
      end
    end

    context 'when media is private' do
      it 'redirects to site root with Not Found flash when accessed through standard route' do
        get :show, params: { id: private_media.access_control_id }

        expect(response).to have_http_status(302)
        expect(response).to redirect_to main_app.root_path(locale: 'en')
      end

      it 'returns 404 not found response when accessed through JSON' do
        get :show, params: { id: private_media.access_control_id }, format: :json

        expect(response).to have_http_status(404)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["message"]).to eq("Not Found")
      end
    end

    context 'when media is private but user has temporary access cookie' do
      let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )} 
      let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

      before do
        allow(subject).to receive(:cookies).and_return(cookie_jar)
      end

      it 'displays iiif manifest' do
        cookie_jar.encrypted["ta_#{temporary_link.media_id}"] = { 
          value: temporary_link.token, 
          expires: temporary_link.expires_at
        }

        get :show, params: { id: private_media.access_control_id }

        expect(response).to have_http_status(200)
        expect(response.body).to include '@context'
      end
    end
  end

  describe 'GET #get_manifest_link' do
    let(:main_app) { Rails.application.routes.url_helpers }
    let(:user)  { create(:confirmed_user) }
    let(:private_media) { create(:media, depositor: user.ms_id ) }
    let(:public_media) { create(:public_media, depositor: user.ms_id ) }

    context "without API key credentials" do
      it "returns 401 unauthorized" do
        get :get_manifest_link, params: { id: private_media.id }, format: :json
        expect(response).to have_http_status(401)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["message"]).to eq("Authentication Required")
      end
    end

    context "with invalid API key credentials that do not belong to a user" do
      it "returns 401 unauthorized" do
        controller.request.env['HTTP_AUTHORIZATION'] = "nonsense"
        get :get_manifest_link, params: { id: private_media.id }, format: :json
        expect(response).to have_http_status(401)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["message"]).to eq("Authentication Required")
      end
    end

    context "with valid API key credentials but user does not have access to media" do
      let(:api_user) { create(:user) }

      it "returns 404 not found" do
        controller.request.env['HTTP_AUTHORIZATION'] = api_user.token
        get :get_manifest_link, params: { id: private_media.id }, format: :json
        expect(response).to have_http_status(404)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body)["message"]).to eq("Not Found")
      end
    end

    context "with valid API key credentials and user has access to media" do
      before do
        private_media.read_users += [user]
        private_media.save
      end

      it "returns response with manifest url" do
        controller.request.env['HTTP_AUTHORIZATION'] = user.token
        get :get_manifest_link, params: { id: private_media.id }, format: :json
        expect(response).to have_http_status(200)
        expect(response.content_type).to eq('application/json')
        expect(JSON.parse(response.body).dig("response", "media", "id")).to eq(private_media.id)
        expect(JSON.parse(response.body).dig("response", "media", "manifest_url")).to be_present
      end
    end
  end
end