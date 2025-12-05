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

        event = double('event')
        allow(event).to receive(:payload).and_return({ object: media })
        allow(event).to receive(:[]).with(:object).and_return(media)
        listener.on_object_deleted(event)

        expect(ProxyDepositRequest.where(work_id: media.id).count).to eq(0)
      end

      it 'is tolerant when there are no requests' do
        ProxyDepositRequest.where(work_id: media.id).destroy_all

        event = double('event')
        allow(event).to receive(:payload).and_return({ object: media })
        allow(event).to receive(:[]).with(:object).and_return(media)
        expect { listener.on_object_deleted(event) }.not_to raise_error
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

        event = double('event')
        allow(event).to receive(:payload).and_return({ object: specimen })
        allow(event).to receive(:[]).with(:object).and_return(specimen)
        listener.on_object_deleted(event)

        expect(ProxyDepositRequest.count).to eq(1)
      end
    end
  end
end
