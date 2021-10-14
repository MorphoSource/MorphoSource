require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::MediaDownloadsController, type: :controller do

  describe "GET #show" do
    let(:user)        { User.create(email: 'user@email.com', password: 'password') }
    let(:depositor)   { User.create(email: 'depositor@email.com', password: 'password') }

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
    end

    describe 'response' do

      context 'media is open' do
        before do
          works.each do |work|
            work.visibility = 'open'
            work.fileset_accessibility = ['open']
            work.save
          end
        end
        it "returns a zip for a single work" do
          get :show, params: { key: [work1.access_control_id], token: user.token }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for multiple works" do
          get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for duplicated works" do
          get :show, params: { key: [work1.access_control_id, work1.access_control_id], token: user.token }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for unique works with conflicting names" do
          get :show, params: { key: [work1.access_control_id, work_dup.access_control_id], token: user.token }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end
      end

      context 'items are restricted' do
        before do
          works.each do |work|
            work.visibility = "open"
            work.fileset_accessibility = ["restricted_download"]
            work.save
          end
        end
        context 'user has download access to one of the items' do
          before do
            allow(subject).to receive(:current_user).and_return(user)
            allow(user).to receive(:can?).with(:download, work1.id).and_return(true)
            allow(user).to receive(:can?).with(:download, work2.id).and_return(false)
            #allow(user).to receive(:downloadable_item_work_ids).and_return([])
          end
          it 'returns unauthorized' do
            get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token }
            expect(response.status).to eq(401)
          end
        end
        context 'user has an approved download for one of the items' do
          before do
            allow(user).to receive(:can?).with(:download, work1.id).and_return(false)
            allow(user).to receive(:can?).with(:download, work2.id).and_return(false)
            allow(user).to receive(:my_approved_requests_work_ids).and_return([work1.id])
          end
          it 'returns unauthorized' do
            get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token }
            expect(response.status).to eq(401)
          end
        end
      end
    end

    describe 'creating or updating cart items' do
      before do
        allow(subject).to receive(:output_dirname).and_return(subject.send(:output_dirname, work1))
      end
      context 'user is authorized to download the media' do
        before do
          allow(user).to receive(:can?).with(:download, work1.id).and_return(true)
          allow(user).to receive(:can?).with(:download, work2.id).and_return(true)
        end

        context 'user has downloadable items' do
          let!(:cart_item1) { CartItem.create(user_id: user.ms_id, work_id: work1.id, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }
          let!(:cart_item2) { CartItem.create(user_id: user.ms_id, work_id: work2.id, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }

          context 'the items have already been downloaded' do
            before do
              [cart_item1, cart_item2].each do |i|
                i.date_downloaded = Date.yesterday
                i.save
              end
            end
            it 'creates new downloaded cart items' do
              expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token } }.to change{CartItem.count}.by(2)
            end
          end
          context 'the items have not been downloaded' do
            it 'marks the items as downloaded' do
              expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token } }.to change{CartItem.count}.by(0)
              [cart_item1, cart_item2].each(&:reload)
              expect(cart_item1.date_downloaded).not_to be(nil)
              expect(cart_item1.date_downloaded).not_to be(nil)
            end
          end
        end

        context 'the user does not have downloadable cart items' do
          it 'creates new downloaded cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token } }.to change{CartItem.count}.by(2)
          end
        end
      end
    end
  end
end
