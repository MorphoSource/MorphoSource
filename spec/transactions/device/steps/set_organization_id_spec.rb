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

    it 'returns success when attributes are nil' do
      obj = double('ChangeSet')
      allow(obj).to receive(:organization_id=)

      result = step.call(obj, attributes: nil)

      expect(result).to be_success
      expect(obj).not_to have_received(:organization_id=)
    end

    it 'sets organization_id from attributes' do
      obj = double('ChangeSet')
      allow(obj).to receive(:organization_id=)

      attributes = { 'organization_id' => ['org-1'], 'work_parents_attributes' => {} }
      allow(OrganizationCollection).to receive(:exists?).and_return(false)

      result = step.call(obj, attributes: attributes)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with(['org-1'])
    end

    it 'fails when more than one organization is present' do
      obj = double('ChangeSet')
      allow(obj).to receive(:organization_id=)

      attributes = {
        'organization_id' => ['org-1'],
        'work_parents_attributes' => { '0' => { 'id' => 'org-2', '_destroy' => 'false' } }
      }
      allow(OrganizationCollection).to receive(:exists?).and_return(false)

      result = step.call(obj, attributes: attributes)

      expect(result).to be_failure
      expect(result.failure[0]).to eq('Cannot associate device with more than one organization')
      expect(result.failure[1]).to eq(obj)
      expect(obj).not_to have_received(:organization_id=)
    end

    it 'removes organization collections from work_parents_attributes' do
      obj = double('ChangeSet')
      allow(obj).to receive(:organization_id=)

      attributes = {
        'organization_id' => [],
        'work_parents_attributes' => { '0' => { 'id' => 'col-1', '_destroy' => 'false' } }
      }
      allow(OrganizationCollection).to receive(:exists?).with('col-1').and_return(true)

      result = step.call(obj, attributes: attributes)

      expect(result).to be_success
      expect(obj).to have_received(:organization_id=).with(['col-1'])
      expect(attributes['work_parents_attributes']).to eq({})
    end
  end
end
