# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::UpdateArkStatus do
  subject(:step) { described_class.new }

  describe '#call' do
    it 'returns failure when the object does not respond to update_ark_status' do
      obj = Object.new

      result = step.call(obj)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:no_update_ark_status)
      expect(result.failure[1]).to eq(obj)
    end

    it 'updates ark status when available' do
      obj = instance_double('Work')
      expect(obj).to receive(:update_ark_status)

      result = step.call(obj)

      expect(result).to be_success
      expect(result.value!).to eq(obj)
    end

    it 'returns failure when update_ark_status raises' do
      obj = instance_double('Work')
      allow(obj).to receive(:update_ark_status).and_raise('boom')

      result = step.call(obj)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:update_ark_status_failed)
      expect(result.failure[1]).to eq(obj)
      expect(result.failure[2]).to eq('boom')
    end
  end
end
