# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::DestroyProxyDepositRequestsListener do
  subject(:listener) { described_class.new }

  let(:depositor) { FactoryBot.create(:contributor) }
  let(:receiver)  { FactoryBot.create(:contributor) }

  describe '#on_object_deleted' do
    context 'when the deleted object is a Media' do
      let!(:media) { FactoryBot.create(:media) }

      before do
        # create some proxy deposit requests tied to this media
        ProxyDepositRequest.create!(work_id: media.id, sending_user: depositor, receiving_user: receiver, status: 'rejected')
        ProxyDepositRequest.create!(work_id: media.id, sending_user: depositor, receiving_user: receiver, status: 'pending')
      end

      it 'destroys all proxy deposit requests for that media' do
        expect(ProxyDepositRequest.where(work_id: media.id).count).to eq(2)

        listener.on_object_deleted(object: media)

        expect(ProxyDepositRequest.where(work_id: media.id).count).to eq(0)
      end

      it 'is tolerant when there are no requests' do
        ProxyDepositRequest.where(work_id: media.id).destroy_all

        expect { listener.on_object_deleted(object: media) }.not_to raise_error
      end
    end

    context 'when the deleted object is not a Media' do
      let!(:media) { FactoryBot.create(:media) }
      let!(:specimen) { FactoryBot.create(:biological_specimen) }

      before do
        ProxyDepositRequest.create!(work_id: media.id, sending_user: depositor, receiving_user: receiver, status: 'pending')
      end

      it 'does not destroy requests for other works' do
        expect(ProxyDepositRequest.count).to eq(1)

        listener.on_object_deleted(object: specimen)

        expect(ProxyDepositRequest.count).to eq(1)
      end
    end
  end
end
