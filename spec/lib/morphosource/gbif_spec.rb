# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::Gbif do

  it { expect(described_class::API_ENDPOINT).to eq('https://api.gbif.org/v1') }

  describe '.search' do
    let(:name)  { 'canis familiaris' }

    context 'search request is not valid' do
      let(:request_url) { 'https://api.gbif.org/v1/species/asdfasd' }
      let(:fail_data)   {
                          { 'message' => '400 Bad Request',
                            'request_url' => 'https://api.gbif.org/v1/species/asdfasd',
                            'params' => {} }
                        }

      it 'returns a fail status' do
        results = described_class.search_gbif(request_url)
        expect(results[:status]).to eq(:fail)
        expect(results[:data]).to eq(fail_data)
      end
    end

    context 'search is successful' do
      it 'returns json search results' do
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:success)
        expect(results[:data].map { |r| r['vernacularName'] }).to include('dog')
      end
    end

    context 'response code is not 200' do
      let(:response)  { instance_double(RestClient::Response, code: 304) }
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end
      it 'returns a success status with response code' do
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:fail)
        expect(results[:data]).to eq("Response code: #{response.code}")
      end
    end

    context 'response.body parsing fails' do
      let(:response)  { instance_double(RestClient::Response, code: 200, body: nil) }
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end
      it 'returns an error status' do
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq('Response.body parsing failed.')
      end
    end

    context 'not found error' do
      let(:error) { RestClient::NotFound.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("GBIF returned #{error.message} for #{described_class::API_ENDPOINT}/species")
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end

    context 'timeout error' do
      let(:error) { RestClient::Exceptions::Timeout.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("GBIF returned #{error.message} for #{described_class::API_ENDPOINT}/species")
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end

    context 'some other error' do
      let(:error) { RestClient::Exception.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'returns json search results' do
        expect(Rails.logger).to receive(:error).with("GBIF returned #{error.message} for #{described_class::API_ENDPOINT}/species")
        results = described_class.search(name, described_class.dataset_key)
        expect(results[:status]).to eq(:error)
        expect(results[:message]).to eq(error.message)
      end
    end
  end

  describe '.view' do
    let(:key) { '1647781509' } # https://www.gbif.org/occurrence/1647781509

    context 'viewing an occurrence' do
      it 'returns a json view result' do
        result = described_class.view(key, 'occurrence')
        expect(result[:status]).to eq(:success)
        expect(result[:data]['vernacularName']).to eq('Common Dog')
      end
    end

    context 'viewing a species' do
      let(:key) { '5219200' } # https://www.gbif.org/species/5219200

      it 'returns a json view result' do
        result = described_class.view(key)
        expect(result[:status]).to eq(:success)
        expect(result[:data]['vernacularName']).to eq('dog')
      end
    end

    context 'not found error' do
      let(:error) { RestClient::NotFound.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF returned #{error.message} for #{described_class::API_ENDPOINT}/species/#{key}")

        result = described_class.view(key)
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq(error.message)
      end
    end

    context 'timeout error' do
      let(:error) { RestClient::Exceptions::Timeout.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF returned Request Timeout for #{described_class::API_ENDPOINT}/species/#{key}")
        result = described_class.view(key)
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq(error.message)
      end
    end

    context 'a different error' do
      let(:error) { RestClient::Exception.new }
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(error)
      end
      it 'rescues and returns an empty hash' do
        expect(Rails.logger).to receive(:error).with("GBIF returned #{error} for #{described_class::API_ENDPOINT}/species/#{key}")
        result = described_class.view(key)
        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq(error.message)
      end
    end
  end

  describe '.dataset_key' do
    it { expect(described_class.dataset_key).to eq('d7dddbf4-2cf0-4f39-9b2a-bb099caae36c') }
  end
end
