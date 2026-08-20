require 'rails_helper'

RSpec.describe TransferDecisionJob do
  let(:work)           { FactoryBot.create(:media) }
  let(:sending_user)   { FactoryBot.create(:contributor, email: "sender@email.com", display_name: "Sender") }
  let(:receiving_user) { FactoryBot.create(:contributor, email: "receiver@email.com", display_name: "Receiver") }

  before do
    allow(Hyrax.config).to receive(:host_name) { "test.host" }
  end

  describe 'perform' do
    context 'accept' do
      context 'request already accepted (decision recorded synchronously by the batch flow)' do
        let!(:request) do
          ProxyDepositRequest.create(
            work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id,
            status: 'accepted', sender_comment: 'test'
          )
        end

        it 'applies the accept side effects' do
          described_class.perform_now(request.id, 'accept')
          request.reload
          expect(request.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq receiving_user.user_key
        end

        it 'forwards reset' do
          expect_any_instance_of(ProxyDepositRequest).to receive(:apply_accept_side_effects!).with(reset: true)
          described_class.perform_now(request.id, 'accept', reset: true)
        end

        context 'with sticky' do
          let(:acting_user) { FactoryBot.create(:contributor) }

          it "adds sending_user to acting_user's can_receive_deposits_from" do
            described_class.perform_now(request.id, 'accept', acting_user_id: acting_user.id, sticky: true)
            expect(acting_user.can_receive_deposits_from).to include(sending_user)
          end

          it 'does not add a duplicate if already present' do
            acting_user.can_receive_deposits_from << sending_user
            described_class.perform_now(request.id, 'accept', acting_user_id: acting_user.id, sticky: true)
            expect(acting_user.can_receive_deposits_from.where(id: sending_user.id).count).to eq 1
          end
        end

        context 'side effects fail' do
          before do
            allow_any_instance_of(ProxyDepositRequest).to receive(:apply_accept_side_effects!).and_raise(StandardError, 'boom')
          end

          it 're-raises so the job is marked failed (visible on admin/background_jobs)' do
            expect { described_class.perform_now(request.id, 'accept') }.to raise_error(StandardError, 'boom')
          end
        end
      end

      context 'request still pending (console/manual use, decision not recorded ahead of time)' do
        let!(:request) do
          ProxyDepositRequest.create(
            work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id,
            status: 'pending', sender_comment: 'test'
          )
        end

        it 'records the decision and applies the side effects in one step' do
          described_class.perform_now(request.id, 'accept')
          request.reload
          expect(request.status).to eq 'accepted'
          work.reload
          expect(work.owner).to eq receiving_user.user_key
        end
      end

      context 'request already resolved to something else' do
        let!(:request) do
          ProxyDepositRequest.create(
            work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'rejected'
          )
        end

        it 'is a no-op' do
          expect_any_instance_of(ProxyDepositRequest).not_to receive(:transfer!)
          expect_any_instance_of(ProxyDepositRequest).not_to receive(:apply_accept_side_effects!)
          described_class.perform_now(request.id, 'accept')
        end
      end
    end

    # The transfers dashboards apply reject/cancel/force_cancel synchronously in the controller
    # (see Morphosource::TransfersControllerBehavior#process_batch_decisions) since they have no slow
    # side effects; these decisions stay supported here for manual/console use.
    context 'reject' do
      let!(:request) do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      end

      it 'marks the request rejected' do
        described_class.perform_now(request.id, 'reject', comment: 'not needed')
        request.reload
        expect(request.status).to eq 'rejected'
        expect(request.receiver_comment).to eq 'not needed'
      end
    end

    context 'cancel' do
      let!(:request) do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      end

      it 'marks a standard request canceled' do
        described_class.perform_now(request.id, 'cancel')
        request.reload
        expect(request.status).to eq 'canceled'
      end

      context 'organization transfer' do
        before { request.update_column(:organization_transfer, true) }

        it 'raises, since senders cannot cancel organization transfers' do
          expect { described_class.perform_now(request.id, 'cancel') }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'force_cancel' do
      let!(:request) do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      end

      before { request.update_column(:organization_transfer, true) }

      it 'bypasses the organization transfer cancellation restriction' do
        described_class.perform_now(request.id, 'force_cancel')
        request.reload
        expect(request.status).to eq 'canceled'
      end
    end

    context 'request no longer exists' do
      it 'is a no-op' do
        expect { described_class.perform_now(0, 'accept') }.not_to raise_error
      end
    end

    context 'unrecognized decision' do
      let!(:request) do
        ProxyDepositRequest.create(work_id: work.id, sending_user_id: sending_user.id, receiving_user_id: receiving_user.id, status: 'pending')
      end

      it 'is a no-op' do
        expect_any_instance_of(ProxyDepositRequest).not_to receive(:transfer!)
        described_class.perform_now(request.id, 'bogus')
      end
    end
  end
end
