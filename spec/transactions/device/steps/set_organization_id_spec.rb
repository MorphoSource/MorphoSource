# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::SetOrganizationID do
  subject(:step) { described_class.new }

  let(:change_set) do
    cs = double('ChangeSet')
    allow(cs).to receive(:organization_id=)
    cs
  end

  describe '#call' do
    it 'returns failure when the object does not respond to organization_id=' do
      obj = Object.new

      result = step.call(obj, organization_id: 'org-1')

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:no_organization_id)
      expect(result.failure[1]).to eq(obj)
    end

    context 'when organization_id is provided' do
      it 'sets organization_id and returns success' do
        result = step.call(change_set, organization_id: 'org-1')

        expect(result).to be_success
        expect(change_set).to have_received(:organization_id=).with(['org-1'])
      end

      it 'returns failure when more than one organization is given' do
        result = step.call(change_set, organization_id: ['org-1', 'org-2'])

        expect(result).to be_failure
        expect(result.failure[0]).to eq(:multiple_organizations)
        expect(change_set).not_to have_received(:organization_id=)
      end
    end

    context 'when organization_id is not provided (nil default)' do
      it 'returns success without modifying the change_set' do
        result = step.call(change_set)

        expect(result).to be_success
        expect(change_set).not_to have_received(:organization_id=)
      end
    end

    context 'when organization_id is explicitly nil' do
      it 'returns success without modifying the change_set' do
        result = step.call(change_set, organization_id: nil)

        expect(result).to be_success
        expect(change_set).not_to have_received(:organization_id=)
      end
    end

    context 'when organization_id is a blank string' do
      it 'returns success without modifying the change_set' do
        result = step.call(change_set, organization_id: '')

        expect(result).to be_success
        expect(change_set).not_to have_received(:organization_id=)
      end
    end
  end
end
