require 'rails_helper'

RSpec.describe Morphosource::My::TransfersSentController, type: :controller do
  let(:sending_user)   { FactoryBot.create(:contributor) }
  let(:receiving_user) { FactoryBot.create(:contributor) }
  let(:work)           { FactoryBot.create(:media) }

  before do
    ActiveJob::Base.queue_adapter = :test
    allow(subject).to receive(:current_user).and_return(sending_user)
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

    it 'defaults to showing only pending requests' do
      pending_request = ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      other_work = FactoryBot.create(:media)
      accepted_request = ProxyDepositRequest.create(work_id: other_work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      accepted_request.update_column(:status, 'accepted')

      get :index
      expect(assigns(:items)).to match_array([pending_request])
    end
  end

  describe 'PUT #batch_cancel' do
    let!(:request1) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    it 'cancels the selected request synchronously, with no job needed' do
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_cancel, params: { batch_document_ids: [request1.id] }
      expect(request1.reload.status).to eq 'canceled'
      expect(response).to redirect_to(transfers_sent_path)
    end

    it 'does not force-cancel an organization transfer, since a sender cannot destroy one' do
      request1.update_column(:organization_transfer, true)
      put :batch_cancel, params: { batch_document_ids: [request1.id] }
      expect(request1.reload.status).to eq 'pending'
    end

    it 'does not enqueue a job for another user''s request' do
      other_request = ProxyDepositRequest.create(work_id: FactoryBot.create(:media).id, sending_user_id: FactoryBot.create(:contributor).id, receiving_user_id: receiving_user.id, status: 'pending')
      expect(TransferDecisionJob).not_to receive(:perform_later)
      put :batch_cancel, params: { batch_document_ids: [other_request.id] }
    end
  end
end
