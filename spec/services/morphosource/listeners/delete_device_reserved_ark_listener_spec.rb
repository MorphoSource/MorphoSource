# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::DeleteDeviceReservedArkListener do
  subject(:listener) { described_class.new }

  describe '#on_object_deleted' do
    it 'enqueues with deleted_ark from event payload' do
      resource = build(:device_resource, id: Valkyrie::ID.new('abc-123'), ark: ['ark:/99999/fk4/old'])
      event = instance_double('Dry::Event', payload: { object: resource, deleted_ark: 'ark:/99999/fk4/payload' })

      expect(DeleteReservedArkJob).to receive(:perform_later).with('ark:/99999/fk4/payload')

      listener.on_object_deleted(event)
    end

    it 'falls back to object ark when deleted_ark is not present' do
      resource = build(:device_resource, id: Valkyrie::ID.new('abc-123'), ark: ['ark:/99999/fk4/object'])
      event = instance_double('Dry::Event', payload: { object: resource })

      expect(DeleteReservedArkJob).to receive(:perform_later).with('ark:/99999/fk4/object')

      listener.on_object_deleted(event)
    end

    it 'does not enqueue for non-device resources' do
      event = instance_double('Dry::Event', payload: { object: instance_double('TaxonomyResource') })

      expect(DeleteReservedArkJob).not_to receive(:perform_later)

      listener.on_object_deleted(event)
    end
  end
end
