require 'rails_helper'

RSpec.describe Morphosource::DerivativeDownloadsController do
  describe "GET #show" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:public_file_set) do
      create(:file_set, :public, user: user, content: File.open(fixture_path + '/images/duke.png'))
    end
    let(:private_file_set) do
      create(:file_set, user: user, content: File.open(fixture_path + '/images/duke.png'))
    end
    let(:private_media) { create(:media, depositor: user.ms_id) }
    let(:public_media) { create(:public_media, depositor: user.ms_id) }

    context 'from public media' do
      before do
        public_media.ordered_members << public_file_set
        public_media.save
      end

      context 'thumbnail request' do
        let(:file) { File.open(fixture_path + '/images/ms.jpg', 'rb') }
        let(:content) { file.read }
  
        before do
          allow(Morphosource::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/images/ms.jpg')
        end
  
        it 'sends requested file content' do
          get :show, params: { id: public_media.id, file: 'thumbnail' }
          expect(response).to be_success
          expect(response.body).to eq content
          expect(response.headers['Content-Length']).to eq "25806"
          expect(response.headers['Accept-Ranges']).to eq "bytes"
        end
  
        it 'retrieves the thumbnail without contacting Fedora' do
          expect(ActiveFedora::Base).not_to receive(:find).with(public_media.id)
          expect(ActiveFedora::Base).not_to receive(:find).with(public_file_set.id)
          get :show, params: { id: public_media.id, file: 'thumbnail' }
        end
      end

      context '3D derivative preview request' do
        before do
          allow(Morphosource::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/bunny/bunny.glb')
        end
  
        it 'sends requested file content' do
          get :show, params: { id: public_file_set.access_control_id, file: 'glb' }
          expect(response).to be_success
          expect(response.content_type).to eq 'model/gltf+json'
          expect(response.headers['Content-Length']).to eq "1254180"
          expect(response.headers['Accept-Ranges']).to eq "bytes"
        end
      end
    end

    context 'from private media' do
      before do
        private_media.ordered_members << private_file_set
        private_media.save!
      end

      context 'thumbnail request' do
        let(:file) { File.open(fixture_path + '/images/ms.jpg', 'rb') }
        let(:content) { file.read }
  
        before do
          allow(Morphosource::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/images/ms.jpg')
        end


        context 'user is not logged in' do
          it 'sends default image with unauthorized status code' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to have_http_status(:unauthorized)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user is logged in and has user-level access' do
          before do
            sign_in user
            private_media.read_users += [user]
            private_media.save
            private_file_set.read_users += [user]
            private_file_set.save
          end

          it 'sends requested file content' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end
        end

        context 'user is logged in but does not have access' do
          before do
            sign_in other_user
          end

          it 'sends default image with unauthorized status code' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to have_http_status(:unauthorized)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user has temporary access cookie' do
          let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )} 
          let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

          before do
            allow(subject).to receive(:cookies).and_return(cookie_jar)
            cookie_jar.encrypted[private_media.id] = temporary_link.token
          end

          context 'user is not logged in' do
            it 'sends requested file content' do
              get :show, params: { id: private_media.id, file: 'thumbnail' }
              expect(response).to be_success
              expect(response.body).to eq content
              expect(response.headers['Content-Length']).to eq "25806"
              expect(response.headers['Accept-Ranges']).to eq "bytes"
            end
          end

          context 'user is logged in and has user-level access' do
            before do
              sign_in user
              private_media.read_users += [user]
              private_media.save
              private_file_set.read_users += [user]
              private_file_set.save
            end

            it 'sends requested file content' do
              get :show, params: { id: private_media.id, file: 'thumbnail' }
              expect(response).to be_success
              expect(response.body).to eq content
              expect(response.headers['Content-Length']).to eq "25806"
              expect(response.headers['Accept-Ranges']).to eq "bytes"
            end
          end

          context 'user is logged in but does not have user-level access' do
              before do
                sign_in other_user
              end

              it 'sends requested file content' do
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end
          end
        end
      end

      context '3D derivative preview request' do  
        before do
          allow(Morphosource::DerivativePath).to receive(:derivative_path_for_reference).and_return(fixture_path + '/bunny/bunny.glb')
        end


        context 'user is not logged in' do
          it 'sends default image with unauthorized status code' do
            get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
            expect(response).to have_http_status(:unauthorized)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user is logged in and has user-level access' do
          before do
            sign_in user
            private_media.read_users += [user]
            private_media.save
            private_file_set.read_users += [user]
            private_file_set.save
          end

          it 'sends requested file content' do
            get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
            expect(response).to be_success
            expect(response.content_type).to eq 'model/gltf+json'
            expect(response.headers['Content-Length']).to eq "1254180"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end
        end

        context 'user is logged in but does not have access' do
          before do
            sign_in other_user
          end

          it 'sends default image with unauthorized status code' do
            get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
            expect(response).to have_http_status(:unauthorized)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user has temporary access cookie' do
          let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )} 
          let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

          before do
            allow(subject).to receive(:cookies).and_return(cookie_jar)
            cookie_jar.encrypted[private_media.id] = temporary_link.token
          end

          context 'user is not logged in' do
            it 'sends requested file content' do
              get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
              expect(response).to be_success
              expect(response.content_type).to eq 'model/gltf+json'
              expect(response.headers['Content-Length']).to eq "1254180"
              expect(response.headers['Accept-Ranges']).to eq "bytes"
            end
          end

          context 'user is logged in and has user-level access' do
            before do
              sign_in user
              private_media.read_users += [user]
              private_media.save
              private_file_set.read_users += [user]
              private_file_set.save
            end

            it 'sends requested file content' do
              get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
              expect(response).to be_success
              expect(response.content_type).to eq 'model/gltf+json'
              expect(response.headers['Content-Length']).to eq "1254180"
              expect(response.headers['Accept-Ranges']).to eq "bytes"
            end
          end

          context 'user is logged in but does not have user-level access' do
              before do
                sign_in other_user
              end

              it 'sends requested file content' do
                get :show, params: { id: private_file_set.access_control_id, file: 'glb' }
                expect(response).to be_success
                expect(response.content_type).to eq 'model/gltf+json'
                expect(response.headers['Content-Length']).to eq "1254180"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end
          end
        end
      end
    end
  end

  describe "derivative_download_options" do
    context "when file returned is png" do
      before do
        allow(controller).to receive(:default_file).and_return 'world.png'
      end

      subject { controller.send(:derivative_download_options) }

      it { is_expected.to eq(disposition: 'inline', type: 'image/png') }
    end

    context "when file returned is glb" do
      before do
        allow(controller).to receive(:default_file).and_return 'world.glb'
      end
      
      subject { controller.send(:derivative_download_options) }

      it { is_expected.to eq(disposition: 'inline', type: 'model/gltf+json') }
    end
  end
end