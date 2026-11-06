require 'rails_helper'

RSpec.describe Morphosource::SpecimenSources::Record do
  let(:source) { Morphosource::SpecimenSources::IDigBioSource.new }
  let(:provider_taxonomy_params) { { 'taxonomy_genus' => 'Cyanocitta' } }

  subject(:record) do
    described_class.new(
      source: source, id: 'uuid1', dataset_id: 'rs1', occurrence_id: 'urn:catalog:TEST:VP:1234',
      specimen_params: {}, provider_taxonomy_params: provider_taxonomy_params, raw: {}
    )
  end

  describe '#taxonomy_param_sets' do
    it 'returns provider and GBIF taxonomy params' do
      allow(source).to receive(:gbif_taxonomy_params).and_return('gbif_key' => '2482592')
      expect(record.taxonomy_param_sets).to eq(provider: provider_taxonomy_params, gbif: { 'gbif_key' => '2482592' })
    end

    it 'returns empty GBIF params when the GBIF lookup raises' do
      allow(source).to receive(:gbif_taxonomy_params).and_raise(NoMethodError, 'boom')
      expect(Rails.logger).to receive(:error).with(/GBIF taxonomy lookup failed for iDigBio uuid1: boom/)
      expect(record.taxonomy_param_sets).to eq(provider: provider_taxonomy_params, gbif: {})
    end
  end
end
