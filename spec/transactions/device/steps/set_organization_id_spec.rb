# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::SetOrganizationID do
  subject(:step) { described_class.new }

  describe '#call' do
    it 'returns failure when the object does not respond to organization_id=' do
      obj = Object.new

      result = step.call(obj, attributes: {})

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:no_organization_id)
      expect(result.failure[1]).to eq(obj)
    end

    it 'returns success when no org value is provided' do
      obj = double('ChangeSet')
      allow(obj).to receive(:to_h).and_return({ 'organization_id' => [] })
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with([])
    end

    it 'falls back to request params when input params do not include organization_id' do
      controller = double('Controller', params: {
        'device_resource' => { 'organization_id' => ['org-2'] }
      })
      obj = double('ChangeSet', controller: controller)
      allow(obj).to receive(:to_h).and_return({})
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with(['org-2'])
    end

    it 'clears organization when input_params explicitly provides blank values' do
      obj = double('ChangeSet', input_params: { 'organization_id' => [] })
      allow(obj).to receive(:to_h).and_return({})
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with([])
    end

    it 'reads organization_id from controller params when form did not provide values' do
      controller = double('Controller', params: {
        'organization_id' => 'org-1',
        'device_resource' => { 'organization_id' => ['org-2'] }
      })
      obj = double('ChangeSet', controller: controller)
      allow(obj).to receive(:to_h).and_return({})
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with(['org-1'])
    end

    it 'falls back to empty when no form or request organization_id is provided' do
      obj = double('ChangeSet')
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with([])
    end

    it 'fails when more than one organization is present' do
      obj = double('ChangeSet')
      allow(obj).to receive(:input_params).and_return({ 'organization_id' => ['org-1', 'org-2'] })
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: { 'organization_id' => ['org-1', 'org-2'] })

      expect(result).to be_failure
      expect(result.failure[0]).to eq('Cannot associate device with more than one organization')
      expect(result.failure[1]).to eq(obj)
      expect(obj).not_to have_received(:organization_id=)
    end

    it 'filters blank organization ids' do
      obj = double('ChangeSet')
      allow(obj).to receive(:input_params).and_return({ 'organization_id' => ['', nil] })
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: {})

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with([])
    end
  end
end
