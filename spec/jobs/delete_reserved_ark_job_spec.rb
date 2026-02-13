# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeleteReservedArkJob do
  describe '#perform' do
    it 'deletes reserved ark identifiers' do
      ark = 'ark:/99999/fk4/123'
      identifier = instance_double('Ezid::Identifier', status: 'reserved')

      allow(Ezid::Identifier).to receive(:find).with(ark).and_return(identifier)
      allow(identifier).to receive(:delete)

      described_class.perform_now(ark)

      expect(identifier).to have_received(:delete)
    end

    it 'does not delete non-reserved identifiers' do
      ark = 'ark:/99999/fk4/123'
      identifier = instance_double('Ezid::Identifier', status: 'public')

      allow(Ezid::Identifier).to receive(:find).with(ark).and_return(identifier)
      allow(identifier).to receive(:delete)

      described_class.perform_now(ark)

      expect(identifier).not_to have_received(:delete)
    end
  end
end
