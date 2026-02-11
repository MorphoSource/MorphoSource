# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MigrateResourcesJob do
  describe '#perform' do
    it 'migrates a Device to DeviceResource and indexes it' do
      user = FactoryBot.create(:user)
      device = FactoryBot.create(
        :device,
        title: ['Device A'],
        creator: [user.ms_id],
        depositor: user.ms_id
      )

      old_doc = SolrDocument.find(device.id)
      expect(old_doc['has_model_ssim']).to include('Device')

      described_class.perform_now(ids: [device.id])

      new_doc = SolrDocument.find(device.id)
      expect(new_doc['has_model_ssim']).to include('DeviceResource')
      expect(new_doc['has_model_ssim']).not_to include('Device')
    end
  end
end
