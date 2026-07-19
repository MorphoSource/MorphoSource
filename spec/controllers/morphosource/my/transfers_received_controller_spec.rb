require 'rails_helper'

RSpec.describe Morphosource::My::TransfersReceivedController, type: :controller do
  let(:receiving_user) { FactoryBot.create(:contributor) }
  let(:sending_user)   { FactoryBot.create(:contributor) }
  let(:work)           { FactoryBot.create(:media) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(subject).to receive(:current_user).and_return(receiving_user)
  end

  describe 'GET #index' do
    it "can not be accessed without a signed-in user" do
      allow(subject).to receive(:current_user).and_return(nil)
      get :index
      expect(response).to redirect_to(new_user_session_path)
    end

    it "is accessible to a signed-in user" do
      get :index
      expect(response.status).to eq(200)
    end

    context 'default status filter' do
      let!(:pending_request) do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      end
      let!(:accepted_request) do
        req = ProxyDepositRequest.create(work_id: FactoryBot.create(:media).id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
        req.update_column(:status, 'accepted')
        req
      end

      it 'shows only pending requests when no status filter is given' do
        get :index
        expect(assigns(:items)).to match_array([pending_request])
      end

      it 'shows the requested status when filter_items[status] is given' do
        get :index, params: { filter_items: { status: 'accepted' } }
        expect(assigns(:items)).to match_array([accepted_request])
      end

      it 'shows all statuses when all_statuses=true' do
        get :index, params: { all_statuses: 'true' }
        expect(assigns(:items)).to match_array([pending_request, accepted_request])
      end
    end

    context '@has_organization_transfers' do
      it 'is false when there are no organization transfers' do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
        get :index, params: { all_statuses: 'true' }
        expect(assigns(:has_organization_transfers)).to be false
      end

      it 'is true when an organization transfer exists, independent of the active filter' do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending', organization_transfer: true)
        get :index # default pending filter
        expect(assigns(:has_organization_transfers)).to be true
      end
    end
  end

  describe 'PUT #batch_accept' do
    let!(:request1) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    it 'records the decision synchronously and enqueues a TransferDecisionJob for the side effects' do
      expect(TransferDecisionJob).to receive(:perform_later).with(request1.id, 'accept', acting_user_id: receiving_user.id, reset: false, sticky: false)
      put :batch_accept, params: { batch_document_ids: [request1.id] }
      expect(request1.reload.status).to eq 'accepted'
      expect(response).to redirect_to(transfers_received_path)
    end

    it 'forwards reset and sticky params' do
      expect(TransferDecisionJob).to receive(:perform_later).with(request1.id, 'accept', acting_user_id: receiving_user.id, reset: true, sticky: true)
      put :batch_accept, params: { batch_document_ids: [request1.id], reset: 'true', sticky: 'true' }
    end

    it 'does not enqueue a job for a request the user is not authorized for' do
      other_request = ProxyDepositRequest.create(work_id: FactoryBot.create(:media).id, sending_user_id: sending_user.id, receiving_user_id: FactoryBot.create(:contributor).id, status: 'pending')
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_accept, params: { batch_document_ids: [other_request.id] }
    end

    it 'does not enqueue a job for a request that is no longer pending' do
      request1.update_column(:status, 'accepted')
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_accept, params: { batch_document_ids: [request1.id] }
    end
  end

  describe 'PUT #batch_reject' do
    let!(:request1) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    it 'rejects the selected request synchronously, with no job needed' do
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_reject, params: { batch_document_ids: [request1.id] }
      expect(request1.reload.status).to eq 'rejected'
      expect(response).to redirect_to(transfers_received_path)
    end
  end
end
