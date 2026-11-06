require 'rails_helper'

RSpec.describe Morphosource::SpecimenSources do
  describe '.configured' do
    around do |example|
      original = Hyrax.config.specimen_record_sources
      example.run
      Hyrax.config.specimen_record_sources = original
    end

    it 'builds the configured sources in priority order' do
      Hyrax.config.specimen_record_sources = [:gbif, :idigbio]
      expect(described_class.configured.map(&:class))
        .to eq([Morphosource::SpecimenSources::GbifSource, Morphosource::SpecimenSources::IDigBioSource])
    end

    it 'raises for an unknown source key' do
      Hyrax.config.specimen_record_sources = [:nope]
      expect { described_class.configured }.to raise_error(KeyError)
    end
  end
end
