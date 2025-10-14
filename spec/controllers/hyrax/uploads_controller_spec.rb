require 'rails_helper'

RSpec.describe Hyrax::UploadsController do
  let(:user) { FactoryBot.create(:contributor) }

  describe "#create" do
    let(:file) { File.open(fixture_path + '/bunny/bunny.ply') }

    context "when signed in" do
      before do
        sign_in user
      end

      context "when sending file as single chunk" do
        it "is successful" do
          post :create, params: {
            files: [file],
            upload_hash: SecureRandom.uuid,
            format: 'json'
          }
          expect(response).to have_http_status(:success)
          expect(assigns(:upload)).to be_kind_of Hyrax::UploadedFile
          expect(assigns(:upload)).to be_persisted
          expect(assigns(:upload).user).to eq user
        end
      end

      context "when sending file as multiple chunks" do
        let(:file_chunk1) { Rack::Test::UploadedFile.new(StringIO.new(file.read(5000)), original_filename: 'bunny.ply') }
        let(:file_chunk2) { Rack::Test::UploadedFile.new(StringIO.new(file.read(5000)), original_filename: 'bunny.ply') }
        let(:file_chunk3) { Rack::Test::UploadedFile.new(StringIO.new(file.read), original_filename: 'bunny.ply') }
        let(:upload_hash) { SecureRandom.uuid }

        it "is successful" do
          # upload first chunk
          post :create, params: {
              files: [file_chunk1],
              upload_hash: upload_hash,
              format: 'json'
            }
          expect(response).to have_http_status(:success)
          expect(assigns(:upload)).to be_kind_of Hyrax::UploadedFile
          expect(assigns(:upload)).to be_persisted
          expect(assigns(:upload).user).to eq user
          expect(Hyrax::UploadedFile.exists?(file: 'bunny.ply', upload_hash: upload_hash)).to be true
          expect(Hyrax::UploadedFile.where(file: 'bunny.ply', upload_hash: upload_hash).count).to eq 1
          expect(Hyrax::UploadedFile.find_by(file: 'bunny.ply', upload_hash: upload_hash).file.size).to eq 5000

          # upload second chunk
          request.headers.merge!({ "CONTENT-RANGE" => "bytes 5000-10000/#{file.size}" })
          post :create, params: { files: [file_chunk2], upload_hash: upload_hash, format: 'json' }
          expect(Hyrax::UploadedFile.exists?(file: 'bunny.ply', upload_hash: upload_hash)).to be true
          expect(Hyrax::UploadedFile.where(file: 'bunny.ply', upload_hash: upload_hash).count).to eq 1
          expect(Hyrax::UploadedFile.find_by(file: 'bunny.ply', upload_hash: upload_hash).file.size).to eq 10000

          # upload second chunk
          request.headers.merge!({ "CONTENT-RANGE" => "bytes 10000-#{file.size}/#{file.size}" })
          post :create, params: { files: [file_chunk3], upload_hash: upload_hash, format: 'json' }
          expect(Hyrax::UploadedFile.exists?(file: 'bunny.ply', upload_hash: upload_hash)).to be true
          expect(Hyrax::UploadedFile.where(file: 'bunny.ply', upload_hash: upload_hash).count).to eq 1
          expect(Hyrax::UploadedFile.find_by(file: 'bunny.ply', upload_hash: upload_hash).file.size).to eq file.size
        end
      end
    end

    context "when not signed in" do
      it "returns 404" do
        post :create, params: {
          files: [file],
          upload_hash: SecureRandom.uuid,
          format: 'json'
        }
        expect(response.status).to eq 404
      end
    end
  end

  describe "#destroy" do
    let(:file) { File.open(fixture_path + '/bunny/bunny.ply') }
    let(:uploaded_file) { create(:uploaded_file, file: file, user: user) }

    context "when signed in" do
      before do
        sign_in user
      end
      it "destroys the uploaded file" do
        delete :destroy, params: { id: uploaded_file, format: 'json' }
        expect(response.status).to eq 204
        expect(assigns[:upload]).to be_destroyed
        expect(File.exist?(uploaded_file.file.file.file)).to be false
      end

      context "for a file that doesn't belong to me" do
        let(:uploaded_file) { create(:uploaded_file, file: file) }

        it "doesn't destroy and returns 404" do
          delete :destroy, params: { id: uploaded_file, format: 'json' }
          expect(response.status).to eq 404
          expect(File.exist?(uploaded_file.file.file.file)).to be true
        end
      end
    end

    context "when not signed in" do
      it "is redirected to sign in" do
        delete :destroy, params: { id: uploaded_file }
        expect(response).to redirect_to Rails.application.routes.url_helpers.root_path(locale: 'en')
      end
    end
  end
end
