require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::MediaDownloadsController, type: :controller do

  describe "POST #download_from_api" do
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


    describe 'response' do

      context 'media is open' do
        before do
          work1.visibility = 'open'
          work1.fileset_accessibility = ['open']
          work1.save
          cartitem = CartItem.create( { user_id: user.ms_id, work_id: work1.id, download_hash: download_hash, download_attempts: 0, in_cart: false, download_method: "API" } )
          allow(controller).to receive(:cart_item_for_download_from_api) { cartitem }


        end
        it "returns a zip for multiple works" do

          request.headers["Authorization"] = "#{user.token}"
          request.headers["Accept"] = "application/zip,text/html,application/json"

          payload = {
            id: work1.id,
            key: work1.access_control_id, 
            download: download_hash
          }

          # Make the POST request
          post :download_from_api, params: payload
       byebug   
          expect(response).to have_http_status(:success)


          #post :download_from_api, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash }
          #expect(response.status).to eq(200)
          #expect(response.headers["Content-Type"]).to eq("application/zip")
          #expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          #expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

      end



    end
  end
end
