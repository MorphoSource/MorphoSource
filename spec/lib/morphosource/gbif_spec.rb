require 'rails_helper'

RSpec.describe Morphosource::Gbif do

  it { expect(described_class::API_ENDPOINT).to eq('https://api.gbif.org/v1') }

  describe '.search' do
    let(:name)  { 'canis familiaris' }

    it 'returns json search results' do
      results = described_class.search(name, described_class.dataset_key)
      expect(results.map{|r| r["vernacularName"]}).to include('dog')
    end

    context 'timeout error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::Exceptions::Timeout)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("GBIF request timeout")
        described_class.search(name, described_class.dataset_key)
      end
    end

    context 'some other error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("GBIF request error")
        described_class.search(name, described_class.dataset_key)
      end
    end
  end

  describe '.view' do
    let(:key) { '1647781509' } #https://www.gbif.org/occurrence/1647781509

    context 'viewing an occurrence' do
      it 'returns a json view result' do
        result = described_class.view(key, 'occurrence')
        expect(result["vernacularName"]). to eq('Common Dog')
      end
    end

    context 'viewing a species' do
      let(:key) { '5219200' } # https://www.gbif.org/species/5219200

      it 'returns a json view result' do
        result = described_class.view(key)
        expect(result["vernacularName"]). to eq('dog')
      end
    end

    context 'not found error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::NotFound)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF returned 404 for: #{described_class::API_ENDPOINT}/occurrence/#{key}")
        expect(described_class.view(key, 'occurrence')).to eq({})
      end
    end

    context 'timeout error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::Exceptions::Timeout)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF request timeout")
        expect(described_class.view(key, 'occurrence')).to eq({})
      end
    end

    context 'a different error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF request error")
        expect(described_class.view(key, 'occurrence')).to eq({})
      end
    end
  end

  describe '.dataset_key' do
    it { expect(described_class.dataset_key).to eq('d7dddbf4-2cf0-4f39-9b2a-bb099caae36c') }
  end

end