require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::MediaDownloadsController, type: :controller do

  describe "POST #api_generate_download" do
    let(:user)        { User.create(email: 'user@email.com', password: 'password') }
    let(:depositor)   { User.create(email: 'depositor@email.com', password: 'password') }

    let(:download_hash) { SecureRandom.uuid }

    let(:work1)       { Media.create(title: ["Test Media Work"], depositor: depositor.ms_id) }
    let(:work2)       { Media.create(title: ["Test Media Work 2"], depositor: depositor.ms_id) }
    let(:work_dup)    { Media.create(title: ["Test Media Work"], depositor: depositor.ms_id) }
    let!(:works)       { [work1, work2, work_dup] }

    let(:solr_doc1)   { SolrDocument.new(work1.to_solr) }
    let(:solr_doc2)   { SolrDocument.new(work2.to_solr) }
    let(:solr_doc_dup){ SolrDocument.new(work_dup.to_solr) }

    let(:file_path1)  { fixture_path + '/images/duke.png' }
    let(:file_path2)  { fixture_path + '/images/ms.jpg' }

    let(:local_file1) { File.open(file_path1) }
    let(:local_file2) { File.open(file_path2) }
    let(:local_file_dup) { File.open(file_path1) }

    let(:ability) { double Ability }

    let(:file_set_1)   { FileSet.new(label: 'duke.png') }
    let(:file_set_2)   { FileSet.new(label: 'ms.jpg') }
    let(:file_set_dup) { FileSet.new(label: 'duke.png') }

    let(:use_statement) {"123456789 123456789 123456789 123456789 1234567890"}
    let(:use_categories) {[ "Completing Class Assignment(s) (Grades K-6)", "Art" ]}
    let(:use_category_other) {"Studying for qualifying exams"}

    before do
      sign_in user
      allow(subject).to receive(:current_user).and_return(user)
      allow(subject).to receive(:user_from_token).and_return(user)
      Hydra::Works::AddFileToFileSet.call(file_set_1, local_file1, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_2, local_file2, :original_file, versioning: true)
      Hydra::Works::AddFileToFileSet.call(file_set_dup, local_file_dup, :original_file, versioning: true)

      work1.ordered_members << file_set_1
      work2.ordered_members << file_set_2
      work_dup.ordered_members << file_set_dup

      file_set_1.original_file.file_size = [100]
      file_set_1.original_file.crc32 = [100]
      file_set_1.original_file.save!
      file_set_1.reload

      file_set_2.original_file.file_size = [100]
      file_set_2.original_file.crc32 = [100]
      file_set_2.original_file.save!
      file_set_2.reload

      file_set_dup.original_file.file_size = [100]
      file_set_dup.original_file.crc32 = [100]
      file_set_dup.original_file.save!
      file_set_dup.reload

      allow(SolrDocument).to receive(:find).and_call_original
      works.each do |work|
        allow(SolrDocument).to receive(:find).with(work.id).and_return(SolrDocument.find(work.id))
      end
    end

    describe 'response' do

      context 'media is restricted' do
        before do
          work1.visibility = 'open'
          work1.fileset_accessibility = ["restricted_download"]
          work1.save
          allow(controller).to receive(:download_hash) { download_hash }
        end

        context 'user has no download access' do
          before do
            allow(subject).to receive(:current_user).and_return(user)
            allow(user).to receive(:can?).with(:download, work1.id).and_return(false)
          end

          it 'api_generate_download returns status 404' do
            payload = {
              id: work1.id,
              use_statement: use_statement,
              use_categories: use_categories,
              use_category_other: use_category_other,
              agreements_accepted: true
            }
            request.headers['Authorization'] = user.token 
            request.headers['Accept'] = "application/json"
            request.headers['Content-Type'] = "application/json"
            post :api_generate_download, params: payload
            expect(response.status).to eq(404)
          end

          it 'download_from_api returns status 401' do
            payload = {
              id: work1.id,
              key: work1.access_control_id, 
              download: download_hash
            }
            request.headers['Authorization'] = user.token 
            post :download_from_api, params: payload
            expect(response.status).to eq(401)
          end
        end

        context 'user has download access of not approved item' do
          before do
            allow(subject).to receive(:current_user).and_return(user)
            cartitem = CartItem.create( { user_id: user.ms_id, work_id: work1.id, download_hash: download_hash, download_attempts: 0, in_cart: false, download_method: "API", date_approved: nil } )
            allow(controller).to receive(:cart_item_for_download_from_api) { cartitem }
          end

          it 'api_generate_download returns status 404' do
            payload = {
              id: work1.id,
              use_statement: use_statement,
              use_categories: use_categories,
              use_category_other: use_category_other,
              agreements_accepted: true
            }
            request.headers['Authorization'] = user.token 
            request.headers['Accept'] = "application/json"
            request.headers['Content-Type'] = "application/json"
            post :api_generate_download, params: payload
            expect(response.status).to eq(404)
          end

          it 'download_from_api returns status 401' do
            payload = {
              id: work1.id,
              key: work1.access_control_id, 
              download: download_hash
            }
            request.headers['Authorization'] = user.token 
            post :download_from_api, params: payload
            expect(response.status).to eq(401)
          end
        end

        context 'user has download access of approved item' do
          before do
            allow(subject).to receive(:current_user).and_return(user)
            allow(user).to receive(:can?).with(:download, work1.id).and_return(true)
            allow(user).to receive(:my_approved_requests_work_ids).and_return([work1.id])
            cartitem = CartItem.create( { user_id: user.ms_id, work_id: work1.id, download_hash: download_hash, download_attempts: 0, in_cart: false, download_method: "API", date_approved: Date.yesterday } )
            allow(controller).to receive(:cart_item_for_download_from_api) { cartitem }
          end

          it 'api_generate_download returns status 200' do
            payload = {
              id: work1.id,
              use_statement: use_statement,
              use_categories: use_categories,
              use_category_other: use_category_other,
              agreements_accepted: true
            }
            request.headers['Authorization'] = user.token 
            request.headers['Accept'] = "application/json"
            request.headers['Content-Type'] = "application/json"
            post :api_generate_download, params: payload
            expect(response.status).to eq(200)

            # test each params in the url generated
            resp_media = JSON.parse(response.body)["response"]["media"]
            expect(resp_media["id"]).to eq([work1.id])
            uri = URI.parse(resp_media["download_url"].first)
            params = URI.decode_www_form(uri.query)
            expect(params.assoc("download")&.last).to eq(download_hash)
            expect(params.assoc("key")&.last).to eq(work1.access_control_id)
            expect(URI.decode_www_form_component(params.assoc("usage")&.last)).to eq(use_statement)
            expect(URI.decode_www_form_component(params.assoc("usage_list")&.last)).to eq((use_categories << use_category_other).join(';'))
          end


# test validation errors


#          it 'download_from_api returns status 200' do
#            payload = {
#              id: work1.id,
#              key: work1.access_control_id, 
#              download: download_hash
#            }
#            post :download_from_api, params: payload
#            expect(response.status).to eq(200)
#          end
        end

      end # // media is restricted

#      context 'media is open' do
#        before do
#          work1.visibility = 'open'
#          work1.fileset_accessibility = ['open']
#          work1.save
#          cartitem = CartItem.create( { user_id: user.ms_id, work_id: work1.id, download_hash: download_hash, download_attempts: 0, in_cart: false, download_method: "API" } )
#          #allow(controller).to receive(:cart_item_for_download_from_api) { cartitem }
#        end
#
#        it "returns status 400 for wrong hash" do
#          payload = {
#            id: work1.id,
#            key: work1.access_control_id, 
#            download: "wrong_hash"
#          }
#          post :download_from_api, params: payload
#          expect(response.status).to eq(400)
#        end
#
#        it "returns a zip" do
#          payload = {
#            id: work1.id,
#            key: work1.access_control_id, 
#            download: download_hash
#          }
#          post :download_from_api, params: payload
#
#          expect(response.status).to eq(200)
#          expect(response.headers["Content-Type"]).to eq("application/zip")
#          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
#          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
#        end
#
#      end # // media is open

    end # // response
  end
end
