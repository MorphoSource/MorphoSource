require 'rails_helper'

RSpec.describe Morphosource::AttachmentsController do
  describe "GET #show" do
    let(:user) { create(:user) }
    let(:private_media) { create(:media, depositor: user.ms_id) }
    let(:public_media) { create(:public_media, depositor: user.ms_id) }

    context 'from public media' do
      context 'attachment request' do
        let(:file) { File.open(fixture_path + '/images/ms.jpg', 'rb') }
        let(:content) { file.read }
  
        before do
          allow(Morphosource::AttachmentPath).to receive(:attachment_for_field).and_return(fixture_path + '/images/ms.jpg')
        end
  
        it 'sends requested file content' do
          get :show, params: { id: public_media.id, field: 'attachment' }
          expect(response).to be_success
          expect(response.body).to eq content
          expect(response.headers['Content-Length']).to eq "25806"
          expect(response.headers['Accept-Ranges']).to eq "bytes"
        end
  
        it 'retrieves the thumbnail without contacting Fedora' do
          expect(ActiveFedora::Base).not_to receive(:find).with(public_media.id)
          get :show, params: { id: public_media.id, field: 'attachment' }
        end
      end
    end

    context 'from private media' do

      context 'attachment request' do
        let(:file) { File.open(fixture_path + '/images/ms.jpg', 'rb') }
        let(:content) { file.read }
  
        before do
          allow(Morphosource::AttachmentPath).to receive(:attachment_for_field).and_return(fixture_path + '/images/ms.jpg')
        end


        context 'user is not logged in' do
          it 'sends file not found image with 404 status code' do
            get :show, params: { id: private_media.id, field: 'attachment' }
            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user is logged in and has user-level access' do
          before do
            sign_in user
            private_media.read_users += [user]
            private_media.save
          end

          it 'sends requested file content' do
            get :show, params: { id: private_media.id, field: 'attachment' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end
        end

        context 'user is logged in but does not have access' do
          before do
            sign_in user
          end

          it 'sends file not found image with 404 status code' do
            get :show, params: { id: private_media.id, field: 'attachment' }
            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'image/png'
          end
        end
      end
    end
  end
end