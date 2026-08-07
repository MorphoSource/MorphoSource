require 'rails_helper'

RSpec.describe Hyrax::TransfersController, type: :controller do
  let(:sending_user)   { FactoryBot.create(:contributor, email: "sender@email.com") }
  let(:receiving_user) { FactoryBot.create(:contributor, email: "receiver@email.com") }
  let(:admin)          { FactoryBot.create(:admin) }
  let(:work)           { FactoryBot.create(:media) }

  describe 'GET #index' do
    before { sign_in receiving_user }

    it 'redirects to the new My Transfers Received page' do
      get :index
      expect(response).to redirect_to(transfers_received_path)
    end
  end

  describe 'PUT #accept' do
    let!(:request) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    before { sign_in receiving_user }

    it 'accepts the transfer and redirects back, falling back to the received page' do
      put :accept, params: { id: request.id }
      request.reload
      expect(request.status).to eq 'accepted'
      expect(response).to redirect_to(transfers_received_path)
    end
  end

  describe 'PUT #reject' do
    let!(:request) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    before { sign_in receiving_user }

    it 'rejects the transfer and redirects back, falling back to the received page' do
      put :reject, params: { id: request.id }
      request.reload
      expect(request.status).to eq 'rejected'
      expect(response).to redirect_to(transfers_received_path)
    end
  end

  describe 'DELETE #destroy' do
    let!(:request) { ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending') }

    context 'standard transfer, canceled by the sender' do
      before { sign_in sending_user }

      it 'cancels the transfer and redirects back, falling back to the sent page' do
        delete :destroy, params: { id: request.id }
        request.reload
        expect(request.status).to eq 'canceled'
        expect(response).to redirect_to(transfers_sent_path)
      end
    end

    context 'organization transfer, canceled by an admin' do
      before do
        request.update_column(:organization_transfer, true)
        sign_in admin
      end

      it 'force-cancels the transfer instead of raising' do
        delete :destroy, params: { id: request.id }
        request.reload
        expect(request.status).to eq 'canceled'
        expect(response).to redirect_to(transfers_sent_path)
      end
    end

    context 'organization transfer, canceled by the sender' do
      before do
        request.update_column(:organization_transfer, true)
        sign_in sending_user
      end

      it 'raises, since senders cannot cancel organization transfers' do
        expect { delete :destroy, params: { id: request.id } }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
