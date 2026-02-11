# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Transactions::Device::Steps::AssignID do
  subject(:step) { described_class.new }

  describe '#call' do
    let(:obj) { instance_double('Hyrax::ChangeSet', id: current_id) }

    context 'when id is present' do
      let(:current_id) { 'existing-id' }

      it 'does not mint a new id' do
        allow(::Noid::Rails::Service).to receive(:new)

        result = step.call(obj)

        expect(::Noid::Rails::Service).not_to have_received(:new)
        expect(result).to be_success
      end
    end
  end
end
