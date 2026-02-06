# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::MintArk do
  subject(:step) { described_class.new }

  describe '#call' do
    let(:persister) { instance_double('Hyrax::Persister') }

    it 'returns failure when the object does not respond to mint_ark' do
      obj = Object.new

      result = step.call(obj, persister: persister)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:no_mint_ark)
      expect(result.failure[1]).to eq(obj)
    end

    it 'mints an ark with the provided persister' do
      obj = instance_double('Work')
      expect(obj).to receive(:mint_ark).with(persister: persister).and_return(obj)

      result = step.call(obj, persister: persister)

      expect(result).to be_success
      expect(result.value!).to eq(obj)
    end

    it 'returns failure when mint_ark raises' do
      obj = instance_double('Work')
      allow(obj).to receive(:mint_ark).and_raise('boom')

      result = step.call(obj, persister: persister)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:mint_ark_failed)
      expect(result.failure[1]).to eq(obj)
      expect(result.failure[2]).to eq('boom')
    end
  end
end
