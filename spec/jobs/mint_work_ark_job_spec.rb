# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MintWorkArkJob do
  describe '#perform' do
    it 'mints, saves, and indexes a DeviceResource' do
      work_id = 'device-123'
      resource = instance_double(DeviceResource, ark: [], mint_ark: true)
      saved_resource = instance_double(DeviceResource)

      allow(Hyrax.query_service).to receive(:find_by).with(id: work_id).and_return(resource)
      allow(Hyrax.persister).to receive(:save).with(resource: resource).and_return(saved_resource)
      allow(Hyrax.index_adapter).to receive(:save).with(resource: saved_resource)

      described_class.perform_now(work_id)

      expect(resource).to have_received(:mint_ark)
      expect(Hyrax.persister).to have_received(:save).with(resource: resource)
      expect(Hyrax.index_adapter).to have_received(:save).with(resource: saved_resource)
    end
  end
end
