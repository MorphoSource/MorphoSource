require 'rails_helper'

RSpec.describe Morphosource::ControlledVocabularies::Getty::Tgn do
  let(:cache_key_prefix)  { 'morphosource_getty_tgn_label-v1-' }
  let(:service_name)      { 'tgn' }
  let(:id)                { "http://vocab.getty.edu/tgn/7013625" }
  let(:non_id)            { "http://vocab.getty.edu/tgn/0000"}

  subject { described_class.new(::RDF::URI(id)) }

  it 'has a cache_key_prefix' do
    expect(subject.cache_key_prefix).to eq(cache_key_prefix)
  end

  it 'has a service_name' do
    expect(subject.service_name).to eq(service_name)
  end

  describe 'rdf_label' do
    context 'Faraday response is an error' do
      subject { described_class.new(::RDF::URI(non_id)) }

      let(:error_message) { ["Error fetching 0000"] }

      it 'returns nil' do
        expect(subject.rdf_label).to eq(error_message)
      end
    end

    context 'Faraday response is not an error' do
      let(:preferred_label_value) { "Durham" }

      it 'returns the preferred label value' do
        expect(subject.rdf_label).to eq([preferred_label_value])
      end
    end
  end
end
