require 'rails_helper'
require 'iiif_manifest'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::MediaDownloadsController, type: :controller do

  before do
    Timecop.freeze(Time.local(1999, 9, 9, 9))
  end

  after do
    Timecop.return
  end

  describe "GET #show" do
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

      context 'media is open' do
        before do
          works.each do |work|
            work.visibility = 'open'
            work.fileset_accessibility = ['open']
            work.save
          end
        end
        it "returns a csv manifest for a single work" do
          get :show, params: { key: [work1.access_control_id], token: user.token, download: download_hash }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for multiple works" do
          get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for duplicated works" do
          get :show, params: { key: [work1.access_control_id, work1.access_control_id], token: user.token, download: download_hash }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end

        it "returns a zip for unique works with conflicting names" do
          get :show, params: { key: [work1.access_control_id, work_dup.access_control_id], token: user.token, download: download_hash }
          expect(response.status).to eq(200)
          expect(response.headers["Content-Type"]).to eq("application/zip")
          expect(response.headers["Content-Disposition"]).to start_with('attachment; filename="morphosource_media-')
          expect(response.headers["Content-Disposition"]).to end_with('.zip"')
        end
      end

      context 'keys are provided via session (batch cart download path)' do
        before do
          works.each do |work|
            work.visibility = 'open'
            work.fileset_accessibility = ['open']
            work.save
          end
          session[:download_keys] = {
            download_hash => { "keys" => [work1.access_control_id, work2.access_control_id], "at" => Time.current.to_i }
          }
        end

        it 'resolves media from session without key[] params and returns a zip' do
          get :show, params: { token: user.token, download: download_hash }
          expect(response.status).to eq(200)
          expect(response.headers['Content-Type']).to eq('application/zip')
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
            get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash }
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
            get :show, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash }
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
          allow_any_instance_of(User).to receive(:can?).with(:download, work1.id).and_return(true)
          allow_any_instance_of(User).to receive(:can?).with(:download, work2.id).and_return(true)
          allow_any_instance_of(User).to receive(:can?).with(:download, SolrDocument.find(work1.id)).and_return(true)
          allow_any_instance_of(User).to receive(:can?).with(:download, SolrDocument.find(work2.id)).and_return(true)
        end

        context 'user has already downloaded media using the same download URL hash' do
          let!(:cart_item1) { CartItem.create!(user_id: user.ms_id, work_id: work1.id, in_cart: false, download_hash: download_hash, download_attempts: 1, date_downloaded: Date.yesterday) }
          let!(:cart_item2) { CartItem.create!(user_id: user.ms_id, work_id: work2.id, in_cart: false, download_hash: download_hash, download_attempts: 1, date_downloaded: Date.yesterday) }

          it 'increments download attempts and updates download time on existing downloaded cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(0)
            [cart_item1, cart_item2].each(&:reload)
            expect(cart_item1.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item1.download_attempts).to eq(2)
            expect(cart_item2.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item2.download_attempts).to eq(2)
          end
        end

        context 'user has already downloaded media using a different download URL hash' do
          let!(:cart_item1) { CartItem.create!(user_id: user.ms_id, work_id: work1.id, in_cart: false, download_hash: SecureRandom.uuid, download_attempts: 1, date_downloaded: Date.yesterday) }
          let!(:cart_item2) { CartItem.create!(user_id: user.ms_id, work_id: work2.id, in_cart: false, download_hash: SecureRandom.uuid, download_attempts: 1, date_downloaded: Date.yesterday) }

          it 'creates new downloaded cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(2)
          end
        end

        context 'user has undownload approved requests for these media' do
          let!(:cart_item1) { CartItem.create!(user_id: user.ms_id, work_id: work1.id, download_hash: nil, download_attempts: nil, date_downloaded: nil, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }
          let!(:cart_item2) { CartItem.create!(user_id: user.ms_id, work_id: work2.id, download_hash: nil, download_attempts: 1, date_downloaded: nil, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }

          it 'adds download attempt and hash to existing request cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(0)
            [cart_item1, cart_item2].each(&:reload)
            expect(cart_item1.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item1.download_attempts).to be(1)
            expect(cart_item1.download_hash).to eq(download_hash)
            expect(cart_item2.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item2.download_attempts).to eq(1)
            expect(cart_item2.download_hash).to eq(download_hash)
          end
        end

        context 'user repeats or resumes download of approved requests for these media' do
          let!(:cart_item1) { CartItem.create!(user_id: user.ms_id, work_id: work1.id, download_hash: download_hash, download_attempts: 1, date_downloaded: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }
          let!(:cart_item2) { CartItem.create!(user_id: user.ms_id, work_id: work2.id, download_hash: download_hash, download_attempts: 1, date_downloaded: Date.yesterday, date_approved: Date.yesterday, date_expired: Date.tomorrow, in_cart: true) }

          it 'increments download attempts and updates download time on existing request cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(0)
            [cart_item1, cart_item2].each(&:reload)
            expect(cart_item1.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item1.download_attempts).to be(2)
            expect(cart_item1.download_hash).to eq(download_hash)
            expect(cart_item2.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item2.download_attempts).to eq(2)
            expect(cart_item2.download_hash).to eq(download_hash)
          end
        end

        context 'user has media in cart but has not downloaded them yet' do
          let!(:cart_item1) { CartItem.create!(user_id: user.ms_id, work_id: work1.id, download_hash: nil, download_attempts: nil, date_downloaded: nil, in_cart: true) }
          let!(:cart_item2) { CartItem.create!(user_id: user.ms_id, work_id: work2.id, download_hash: nil, download_attempts: 1, date_downloaded: nil, in_cart: true) }

          it 'adds download attempt and hash to existing request cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(0)
            [cart_item1, cart_item2].each(&:reload)
            expect(cart_item1.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item1.download_attempts).to be(1)
            expect(cart_item1.download_hash).to eq(download_hash)
            expect(cart_item2.date_downloaded.to_date).to eq(Date.today)
            expect(cart_item2.download_attempts).to eq(1)
            expect(cart_item2.download_hash).to eq(download_hash)
          end
        end

        context 'user has no cart items for media' do
          it 'creates new downloaded cart items' do
            expect{ process :show, method: :get, params: { key: [work1.access_control_id, work2.access_control_id], token: user.token, download: download_hash } }.to change{CartItem.count}.by(2)
          end
        end
      end
    end
  end
end
