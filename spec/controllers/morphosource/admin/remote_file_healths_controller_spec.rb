require 'rails_helper'

RSpec.describe Morphosource::Admin::RemoteFileHealthsController, type: :controller do

  describe "GET #index" do
    let(:registered_user)               { FactoryBot.create(:registered_user) }
    let(:contributor)                   { FactoryBot.create(:contributor) }
    let(:batch_submission_contributor)  { FactoryBot.create(:batch_submission_contributor) }
    let(:remote_file_submitter)         { FactoryBot.create(:remote_file_submitter) }
    let(:admin)                         { FactoryBot.create(:admin) }

    it "can not be accessed without user" do
      get :index
      expect(response.status).to eq(302)
    end

    it "can not be accessed by registered user" do
      allow(subject).to receive(:current_user).and_return(registered_user)
      get :index
      expect(response.status).to eq(302)
    end

    it "can not be accessed by contributor" do
      allow(subject).to receive(:current_user).and_return(contributor)
      get :index
      expect(response.status).to eq(302)
    end

    it "can not be accessed by batch submission user" do
      allow(subject).to receive(:current_user).and_return(batch_submission_contributor)
      get :index
      expect(response.status).to eq(302)
    end

    it "can not be accessed by remote_file_submitter" do
      allow(subject).to receive(:current_user).and_return(remote_file_submitter)
      get :index
      expect(response.status).to eq(302)
    end

    it "can be accessed by admin" do
      allow(subject).to receive(:current_user).and_return(admin)
      get :index
      expect(response.status).to eq(200)
    end

    context 'returns only Problematic data' do
      render_views
      let!(:media1) { FactoryBot.create(:media, id: '000200001') }
      let!(:media2) { FactoryBot.create(:media, id: '000200002') }
      let!(:data1) { RemoteFileHealth.create({ media: media1.id, status: "Ok", details: "" }) }
      let!(:data2) { RemoteFileHealth.create({ media: media2.id, status: "Problematic", details: "issues" }) }

      before do
        allow(subject).to receive(:current_user).and_return(admin)
      end

      it 'for standard requests' do
        get :index
        expect(response.body).not_to include data1.media
        expect(response.body).to include data2.media
      end

      it 'for CSV format requests' do
        get :index, params: {format: 'csv'}
        expect(response.content_type).to include('text/csv')
        expect(response.body).not_to include data1.media
        expect(response.body).to include data2.media
      end
    end
  end

  describe 'allowed_sort_parameters' do
    let(:allowed_sort_params) do
      ['media asc',
       'media desc']
    end

    it 'includes custom sort parameters' do
      expect(subject.allowed_sort_parameters).to match_array(allowed_sort_params)
    end
  end
end
