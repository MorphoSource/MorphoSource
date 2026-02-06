# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::DeleteArkIfReserved do
  subject(:step) { described_class.new }

  describe '#call' do
    it 'returns failure when the object does not respond to delete_ark_if_reserved' do
      obj = Object.new

      result = step.call(obj)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:no_delete_ark_if_reserved)
      expect(result.failure[1]).to eq(obj)
    end

    it 'calls delete_ark_if_reserved when available' do
      obj = Class.new do
        def delete_ark_if_reserved; end

        private :delete_ark_if_reserved
      end.new

      expect(obj).to receive(:delete_ark_if_reserved)

      result = step.call(obj)

      expect(result).to be_success
    end

    it 'returns failure when delete_ark_if_reserved raises' do
      obj = Class.new do
        def delete_ark_if_reserved
          raise 'boom'
        end

        private :delete_ark_if_reserved
      end.new

      result = step.call(obj)

      expect(result).to be_failure
      expect(result.failure[0]).to eq(:delete_ark_if_reserved_failed)
      expect(result.failure[1]).to eq(obj)
      expect(result.failure[2]).to eq('boom')
    end
  end
end
