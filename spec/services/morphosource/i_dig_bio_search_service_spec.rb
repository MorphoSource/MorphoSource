require 'rails_helper'
require 'vcr_helper'

RSpec.describe Morphosource::IDigBioSearchService, :vcr do

  subject { described_class.new(params) }

  let(:params) { {} }

  describe '.call' do
    it 'instantiates the search service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(params)
    end
  end

  describe '#call' do
    describe 'no search params' do
      it 'returns an empty array' do
        results = subject.call
        expect(results).to be_a(Array)
        expect(results).to match_array([])
      end
    end
    describe 'some search params' do
      let(:params) { { 'taxonomy_genus' => 'parvisipho', 'taxonomy_species' => 'lewisiana' } }
      it 'returns results that match search params' do
        results = subject.call
        expect(results).to be_a(Array)
        expect(results).not_to be_empty
        expect(results.first['data']['dwc:genus']).to eq('Parvisipho')
        expect(results.first['data']['dwc:specificEpithet']).to eq('lewisiana')
      end
    end
  end

  describe '.biological_specimen_params_from_idigbio' do
    describe 'an IDigBio UUID' do
      let(:uuid) { '061594f4-69a3-41ff-9396-dac55cc8409b' }
      it 'returns params suitable for BiologicalSpecimen construction' do
        results = described_class.biological_specimen_params_from_idigbio(uuid)
        expect(results).to be_a(Hash)
        expect(results['idigbio_uuid']).to eq(uuid)
        expect(results).to have_key('description')
        expect(results).to have_key('idigbio_recordset_id')
        expect(results['vouchered']).to eq('Yes')
      end
    end
  end

  describe '.taxonomy_params_from_idigbio' do
    describe 'an IDigBio UUID' do
      it 'returns params suitable for Taxonomy construction' do
        results = described_class.taxonomy_param_sets_from_idigbio('061594f4-69a3-41ff-9396-dac55cc8409b')
        expect(results).to be_a(Hash)
        expect(results).to have_key(:provider)
        expect(results).to have_key(:gbif)
      end
    end
  end
end
