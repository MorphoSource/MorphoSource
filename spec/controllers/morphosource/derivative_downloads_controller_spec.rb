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

        context 'reference via media id' do
          it 'sends requested file content' do
            get :show, params: { id: public_media.id, file: 'thumbnail' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end

          it 'does not get anything from Fedora' do
            expect(ActiveFedora::Base).not_to receive(:find).with(public_media.id)
            expect(ActiveFedora::Base).not_to receive(:find).with(public_file_set.id)
            get :show, params: { id: public_media.id, file: 'thumbnail' }
          end
        end

        context 'reference via file_set id' do
          it 'sends requested file content' do
            get :show, params: { id: public_file_set.id, file: 'thumbnail' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
          end

          it 'does not get anything from Fedora' do
            expect(ActiveFedora::Base).not_to receive(:find).with(public_media.id)
            expect(ActiveFedora::Base).not_to receive(:find).with(public_file_set.id)
            get :show, params: { id: public_file_set.id, file: 'thumbnail' }
          end
        end

        context 'with default thumbnail' do
          before do
            allow(subject).to receive(:load_file).and_return(Rails.root.join("app", "assets", "images", "work.png").to_s)
          end

          context 'reference via file_set id' do
            it 'sends default image with success status code' do
              get :show, params: { id: public_file_set.id, file: 'thumbnail' }
              expect(response).to have_http_status(200)
              expect(response.content_type).to eq 'image/png'
            end

            it 'does not get anything from Fedora' do
              expect(ActiveFedora::Base).not_to receive(:find).with(public_media.id)
              expect(ActiveFedora::Base).not_to receive(:find).with(public_file_set.id)
              get :show, params: { id: public_file_set.id, file: 'thumbnail' }
            end
          end
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
          it 'sends default image with not found status code' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'image/png'
          end

          context 'user transmits API key' do
            context 'and API key is nonsense' do
              it 'sends default image with not found status code' do
                controller.request.env['HTTP_AUTHORIZATION'] = "nonsense"
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to have_http_status(404)
                expect(response.content_type).to eq 'image/png'
              end
            end

            context 'and API key is valid but does not have access to media' do
              it 'sends default image with not found status code' do
                controller.request.env['HTTP_AUTHORIZATION'] = user.token
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to have_http_status(404)
                expect(response.content_type).to eq 'image/png'
              end
            end

            context 'and API key is valid and has access to media' do
              before do
                private_media.read_users += [user]
                private_media.save
                private_file_set.read_users += [user]
                private_file_set.save
              end

              it 'sends requested file content from media id' do
                controller.request.env['HTTP_AUTHORIZATION'] = user.token
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
              end

              it 'sends requested file content from file_set id' do
                controller.request.env['HTTP_AUTHORIZATION'] = user.token
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
              end
            end
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

          it 'sends requested file content from media id' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
            expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
            expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
          end

          it 'sends requested file content from file_set id' do
            get :show, params: { id: private_file_set.id, file: 'thumbnail' }
            expect(response).to be_success
            expect(response.body).to eq content
            expect(response.headers['Content-Length']).to eq "25806"
            expect(response.headers['Accept-Ranges']).to eq "bytes"
            expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
            expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
          end

          context 'with default thumbnail' do
            before do
              allow(subject).to receive(:load_file).and_return(Rails.root.join("app", "assets", "images", "work.png").to_s)
            end

            it 'sends default image with success http code' do
              get :show, params: { id: private_file_set.id, file: 'thumbnail' }
              expect(response).to have_http_status(200)
              expect(response.content_type).to eq 'image/png'
              expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
              expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
            end
          end
        end

        context 'user is logged in but does not have access' do
          before do
            sign_in other_user
          end

          it 'sends default image with not found status code' do
            get :show, params: { id: private_media.id, file: 'thumbnail' }
            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user has temporary access cookie' do
          let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )}
          let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

          before do
            allow(subject).to receive(:cookies).and_return(cookie_jar)
            cookie_jar.encrypted["ta_#{private_media.id}"] = temporary_link.token
          end

          context 'user is not logged in' do
            context 'reference via media id' do
              it 'sends requested file content' do
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'sends requested content from media id' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_media.id, file: 'thumbnail' }
              end
            end

            context 'reference via file_set id' do
              it 'sends requested file content' do
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'sends requested content from file set id' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
              end
            end

            context 'with default thumbnail' do
              before do
                allow(subject).to receive(:load_file).and_return(Rails.root.join("app", "assets", "images", "work.png").to_s)
              end

              context 'reference via file_set id' do
                it 'sends default image with not found status code' do
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                  expect(response).to have_http_status(404)
                  expect(response.content_type).to eq 'image/png'
                end

                it 'does not get anything from Fedora' do
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                end
              end
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

            context 'reference via media id' do
              it 'sends requested file content' do
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'does not get anything from Fedora' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_media.id, file: 'thumbnail' }
              end
            end

            context 'reference via file_set id' do
              it 'sends requested file content' do
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'does not get anything from Fedora' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
              end
            end

            context 'with default thumbnail' do
              before do
                allow(subject).to receive(:load_file).and_return(Rails.root.join("app", "assets", "images", "work.png").to_s)
              end

              context 'reference via file_set id' do
                it 'sends default image with success status code' do
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                  expect(response).to have_http_status(200)
                  expect(response.content_type).to eq 'image/png'
                end

                it 'does not get anything from Fedora' do
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                end
              end
            end
          end

          context 'user is logged in but does not have user-level access' do
            before do
              sign_in other_user
            end

            context 'reference via media id' do
              it 'sends requested file content' do
                get :show, params: { id: private_media.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'does not get anything from Fedora' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_media.id, file: 'thumbnail' }
              end
            end

            context 'reference via file_set id' do
              it 'sends requested file content' do
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                expect(response).to be_success
                expect(response.body).to eq content
                expect(response.headers['Content-Length']).to eq "25806"
                expect(response.headers['Accept-Ranges']).to eq "bytes"
              end

              it 'gets file_set from Fedora, not media' do
                expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                expect(ActiveFedora::Base).to receive(:find).with(private_file_set.id)
                get :show, params: { id: private_file_set.id, file: 'thumbnail' }
              end
            end

            context 'with default thumbnail' do
              before do
                allow(subject).to receive(:load_file).and_return(Rails.root.join("app", "assets", "images", "work.png").to_s)
              end

              context 'reference via file_set id' do
                it 'sends default image with not found status code' do
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                  expect(response).to have_http_status(404)
                  expect(response.content_type).to eq 'image/png'
                end

                it 'does not get anything from Fedora' do
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_media.id)
                  expect(ActiveFedora::Base).not_to receive(:find).with(private_file_set.id)
                  get :show, params: { id: private_file_set.id, file: 'thumbnail' }
                end
              end
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
            expect(response).to have_http_status(404)
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
            expect(response).to have_http_status(404)
            expect(response.content_type).to eq 'image/png'
          end
        end

        context 'user has temporary access cookie' do
          let(:temporary_link) { create(:temporary_media_access_link, user: user, media_id: private_media.id )}
          let(:cookie_jar) { ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar }

          before do
            allow(subject).to receive(:cookies).and_return(cookie_jar)
            cookie_jar.encrypted["ta_#{private_media.id}"] = temporary_link.token
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
end