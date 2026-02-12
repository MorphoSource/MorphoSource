# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UpdateWorkArkStatusJob do
  describe '#perform' do
    it 'updates ark status for a DeviceResource with an ark' do
      work_id = 'device-123'
      resource = instance_double(DeviceResource, ark: ['ark:/99999/fk4/123'])

      allow(Hyrax.query_service).to receive(:find_by).with(id: work_id).and_return(resource)
      allow(resource).to receive(:update_ark_status)
      allow(Hyrax.persister).to receive(:save)
      allow(Hyrax.index_adapter).to receive(:save)

      described_class.perform_now(work_id)

      expect(resource).to have_received(:update_ark_status)
      expect(Hyrax.persister).not_to have_received(:save)
      expect(Hyrax.index_adapter).not_to have_received(:save)
    end

    it 'does nothing when resource has no ark' do
      work_id = 'device-123'
      resource = instance_double(DeviceResource, ark: [])

      allow(Hyrax.query_service).to receive(:find_by).with(id: work_id).and_return(resource)
      allow(resource).to receive(:update_ark_status)

      described_class.perform_now(work_id)

      expect(resource).not_to have_received(:update_ark_status)
    end

    it 'does nothing for non-device resources' do
      work_id = 'taxonomy-123'
      resource = instance_double('TaxonomyResource')

      allow(Hyrax.query_service).to receive(:find_by).with(id: work_id).and_return(resource)

      expect { described_class.perform_now(work_id) }.not_to raise_error
    end
  end
end
