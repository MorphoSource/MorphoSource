require 'rails_helper'

RSpec.describe Morphosource::Admin::BackgroundJobsController, type: :controller do
  describe "GET #index" do
    let(:registered_user)               { FactoryBot.create(:registered_user) }
    let(:contributor)                   { FactoryBot.create(:contributor) }
    let(:batch_submission_contributor)  { FactoryBot.create(:batch_submission_contributor) }
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

    it "can be accessed by batch submission user" do 
      allow(subject).to receive(:current_user).and_return(batch_submission_contributor)
      get :index
      expect(response.status).to eq(302)
    end

    it "can be accessed by admin" do 
      allow(subject).to receive(:current_user).and_return(admin)
      get :index
      expect(response.status).to eq(200)
    end

    context 'returns all background job data' do
      render_views
      let!(:job1) { BackgroundJob.create({ job_id: 'ewfiuewhfeiuwhf', status: 'working', user_id: batch_submission_contributor.user_key, created_objects: {} }) }
      let!(:job2) { BackgroundJob.create({ job_id: 'ewiuryewiruewr', status: 'working', user_id: contributor.user_key, created_objects: {} }) }
      let!(:job3) { BackgroundJob.create({ job_id: 'mcbxzvkbvmcnxb', status: 'working', user_id: registered_user.user_key, created_objects: {} }) }

      before do
        allow(subject).to receive(:current_user).and_return(admin)
      end

      it 'for standard requests' do
        get :index
        expect(response.body).to include job1.job_id
        expect(response.body).to include job2.job_id
        expect(response.body).to include job3.job_id
      end

      it 'for CSV format requests' do
        get :index, params: {format: 'csv'}
        expect(response.content_type).to eq('text/csv')
        expect(response.body).to include job1.job_id
        expect(response.body).to include job2.job_id
        expect(response.body).to include job3.job_id
      end
    end
  end
end