# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::MintDeviceArkListener do
  subject(:listener) { described_class.new }

  describe '#on_object_deposited' do
    it 'enqueues minting job for a DeviceResource' do
      resource = instance_double(DeviceResource, id: 'abc-123')
      event = instance_double('Dry::Event', payload: { object: resource })

      expect(MintWorkArkJob).to receive(:perform_later).with('abc-123')

      listener.on_object_deposited(event)
    end

    it 'does not enqueue for non-device resources' do
      event = instance_double('Dry::Event', payload: { object: instance_double('TaxonomyResource') })

      expect(MintWorkArkJob).not_to receive(:perform_later)

      listener.on_object_deposited(event)
    end
  end
end
