# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Action::UpdateWorkService do
  describe '#call' do
    it 'updates and indexes a device resource' do
      user = FactoryBot.create(:user)
      device = FactoryBot.valkyrie_create(
        :device_resource,
        with_index: false,
        title: ['Old title'],
        modality: ['MicroCT'],
        creator: [user.ms_id],
        depositor: user.ms_id
      )

      params = { device_resource: { title: ['New title'], creator: [user.ms_id] } }

      result = described_class.new(work: device, params: params).call

      expect(result).to be_success

      solr_doc = SolrDocument.find(device.id.to_s)
      expect(solr_doc['has_model_ssim']).to include('DeviceResource')
      expect(solr_doc['title_tesim']).to include('New title')
    end

    it 'replaces a stale Device solr model with DeviceResource' do
      user = FactoryBot.create(:user)
      device = FactoryBot.valkyrie_create(
        :device_resource,
        with_index: false,
        title: ['Old title'],
        modality: ['MicroCT'],
        creator: [user.ms_id],
        depositor: user.ms_id
      )

      ActiveFedora::SolrService.add(
        { 'id' => device.id.to_s, 'has_model_ssim' => 'Device', 'title_tesim' => ['Old title'] },
        commit: true
      )

      params = { device_resource: { title: ['New title'], creator: [user.ms_id] } }

      result = described_class.new(work: device, params: params).call

      expect(result).to be_success

      solr_doc = SolrDocument.find(device.id.to_s)
      expect(solr_doc['has_model_ssim']).to include('DeviceResource')
      expect(solr_doc['title_tesim']).to include('New title')
    end
  end
end
