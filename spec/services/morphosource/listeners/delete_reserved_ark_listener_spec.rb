# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Listeners::DeleteReservedArkListener do
  subject(:listener) { described_class.new }

  describe '#on_object_deleted' do
    it 'enqueues with deleted_ark from event payload for a device resource' do
      resource = build(:device_resource, id: Valkyrie::ID.new('abc-123'), ark: ['ark:/99999/fk4/old'])
      event = instance_double('Dry::Event', payload: { object: resource, deleted_ark: 'ark:/99999/fk4/payload' })

      expect(DeleteReservedArkJob).to receive(:perform_later).with('ark:/99999/fk4/payload')

      listener.on_object_deleted(event)
    end

    it 'works for any object with deleted_ark in payload' do
      event = instance_double('Dry::Event', payload: { deleted_ark: 'ark:/99999/fk4/payload' })

      expect(DeleteReservedArkJob).to receive(:perform_later).with('ark:/99999/fk4/payload')

      listener.on_object_deleted(event)
    end

    it 'does not enqueue when deleted_ark is missing' do
      event = instance_double('Dry::Event', payload: { object: instance_double('TaxonomyResource') })

      expect(DeleteReservedArkJob).not_to receive(:perform_later)

      listener.on_object_deleted(event)
    end

    it 'enqueues when deleted_ark is provided for non-device resources' do
      event = instance_double('Dry::Event', payload: { object: instance_double('TaxonomyResource'), deleted_ark: 'ark:/99999/fk4/other' })

      expect(DeleteReservedArkJob).to receive(:perform_later).with('ark:/99999/fk4/other')

      listener.on_object_deleted(event)
    end
  end
end
