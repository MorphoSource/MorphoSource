require 'rails_helper'

RSpec.describe Morphosource::ModalitiesService do
  describe '.field_prefix' do
    it 'uses historical overrides for batch manifest modality prefixes' do
      expect(described_class.field_prefix('MicroNanoXRayComputedTomography')).to eq('ct')
      expect(described_class.field_prefix('Photogrammetry')).to eq('photogrammetry')
      expect(described_class.field_prefix('Photography')).to eq('photography')
    end

    it 'uses modality abbreviations for non-overridden modalities' do
      expect(described_class.field_prefix('TransmissionElectronMicroscopy')).to eq('TEM')
    end

    it 'returns Etc for blank values' do
      expect(described_class.field_prefix(nil)).to eq('Etc')
      expect(described_class.field_prefix('')).to eq('Etc')
    end
  end

  describe '.client_lookup' do
    it 'includes term and abbreviation for TEM' do
      lookup = described_class.client_lookup

      expect(lookup['TransmissionElectronMicroscopy']).to eq(
        term: 'Transmission Electron Microscopy',
        abbreviation: 'TEM'
      )
    end

    it 'includes NeutrinoImaging from the authority yaml' do
      lookup = described_class.client_lookup

      expect(lookup['NeutrinoImaging']).to include(
        term: 'Neutrino Imaging',
        abbreviation: 'Neutrino'
      )
    end
  end
end
