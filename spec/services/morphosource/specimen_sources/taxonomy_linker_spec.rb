require 'rails_helper'

RSpec.describe Morphosource::SpecimenSources::TaxonomyLinker do
  let(:provider_params) { { 'taxonomy_genus' => 'Cyanocitta', 'taxonomy_species' => 'stelleri' } }
  let(:gbif_params) { { 'taxonomy_genus' => 'Cyanocitta', 'gbif_key' => '2482492' } }

  subject(:linker) { described_class.call(provider: provider_params, gbif: gbif_params) }

  context 'when matching taxonomies exist' do
    before do
      allow(Morphosource::TaxonomySearchService).to receive(:match_taxonomies_strict)
        .with(provider_params).and_return([SolrDocument.new('id' => 'prov1')])
      allow(Morphosource::TaxonomySearchService).to receive(:call)
        .with({ gbif_key: '2482492' }).and_return([SolrDocument.new('id' => 'gbif1')])
    end

    it 'links them, with the provider taxonomy as canonical' do
      expect(linker.canonical_taxonomy_id).to eq('prov1')
      expect(linker.taxonomy_id_array).to eq(['prov1', 'gbif1'])
      expect(linker.taxonomy_params_array).to be_empty
    end
  end

  context 'when no matching taxonomies exist' do
    before do
      allow(Morphosource::TaxonomySearchService).to receive(:match_taxonomies_strict).and_return([])
      allow(Morphosource::TaxonomySearchService).to receive(:call).and_return([])
    end

    it 'queues params for new taxonomies, flagging the provider one as canonical' do
      expect(linker.canonical_taxonomy_id).to be_nil
      expect(linker.taxonomy_id_array).to be_empty
      expect(linker.taxonomy_params_array.length).to eq(2)
      expect(linker.taxonomy_params_array.first[:canonical]).to eq(true)
      expect(linker.taxonomy_params_array.last[:gbif_key]).to eq('2482492')
    end
  end

  context 'with symbol-keyed provider params' do
    let(:provider_params) { { taxonomy_genus: 'Cyanocitta' } }
    let(:gbif_params) { {} }

    it 'matches using string keys' do
      expect(Morphosource::TaxonomySearchService).to receive(:match_taxonomies_strict)
        .with({ 'taxonomy_genus' => 'Cyanocitta' }).and_return([])
      linker
    end
  end

  context 'with no taxonomy param sets' do
    subject(:linker) { described_class.call(nil) }

    it 'returns nothing to link' do
      expect(linker.to_h).to eq(canonical_taxonomy_id: nil, taxonomy_id_array: [], taxonomy_params_array: [])
    end
  end
end
