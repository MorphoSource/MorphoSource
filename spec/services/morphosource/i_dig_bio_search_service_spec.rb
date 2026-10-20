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
        expect(results).to be_a(Hash)
        expect(results).to include(
          :status => :fail, 
          :data => 'Query parameters must be provided'
        )
      end
    end
    describe 'some search params' do
      let(:params) { { 'taxonomy_genus' => 'parvisipho', 'taxonomy_species' => 'lewisiana' } }
      it 'returns results that match search params' do
        results = subject.call
        expect(results).to be_a(Hash)
        expect(results[:data]).not_to be_empty
        expect(results[:data].first['data']['dwc:genus']).to eq('Parvisipho')
        expect(results[:data].first['data']['dwc:specificEpithet']).to eq('lewisiana')
      end
    end
  end
end
