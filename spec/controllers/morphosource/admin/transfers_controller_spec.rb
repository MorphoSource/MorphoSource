require 'rails_helper'

RSpec.describe Morphosource::Admin::TransfersController, type: :controller do
  let(:contributor)    { FactoryBot.create(:contributor) }
  let(:admin)           { FactoryBot.create(:admin) }
  let(:sending_user)   { FactoryBot.create(:contributor) }
  let(:receiving_user) { FactoryBot.create(:contributor) }
  let(:work)           { FactoryBot.create(:media) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe 'GET #index' do
    it "can not be accessed without a signed-in user" do
      get :index
      expect(response.status).to eq(302)
    end

    it "can not be accessed by a non-admin" do
      allow(subject).to receive(:current_user).and_return(contributor)
      get :index
      expect(response.status).to eq(302)
    end

    it "is accessible to an admin" do
      allow(subject).to receive(:current_user).and_return(admin)
      get :index
      expect(response.status).to eq(200)
    end

    it 'shows every request site-wide, not just those involving the admin' do
      allow(subject).to receive(:current_user).and_return(admin)
      req = ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      get :index
      expect(assigns(:items)).to match_array([req])
    end
  end

  describe 'PUT #batch_cancel' do
    before { allow(subject).to receive(:current_user).and_return(admin) }

    let!(:standard_request) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    it 'uses a plain cancel decision for a standard transfer, with no job needed' do
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_cancel, params: { batch_document_ids: [standard_request.id] }
      expect(standard_request.reload.status).to eq 'canceled'
      expect(response).to redirect_to(admin_transfers_path)
    end

    it 'uses force_cancel for an organization transfer' do
      standard_request.update_column(:organization_transfer, true)
      put :batch_cancel, params: { batch_document_ids: [standard_request.id] }
      expect(standard_request.reload.status).to eq 'canceled'
    end
  end

  describe 'PUT #batch_accept' do
    before { allow(subject).to receive(:current_user).and_return(admin) }

    let!(:request1) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    it 'records the decision synchronously and enqueues a TransferDecisionJob for the side effects' do
      expect(TransferDecisionJob).to receive(:perform_later).with(request1.id, 'accept', acting_user_id: admin.id, reset: false, sticky: false)
      put :batch_accept, params: { batch_document_ids: [request1.id] }
      expect(request1.reload.status).to eq 'accepted'
      expect(response).to redirect_to(admin_transfers_path)
    end
  end
end
