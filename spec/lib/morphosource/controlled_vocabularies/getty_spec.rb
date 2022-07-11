require 'rails_helper'

RSpec.describe Morphosource::ControlledVocabularies::Getty do
  let(:aat_id)   { '300172528' }
  let(:aat_term) { Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI("http://vocab.getty.edu/aat/#{aat_id}")) }

  before(:each) do
    Rails.cache.clear
  end

  describe 'rdf_label' do
    context 'fetching label is successful' do
      it 'returns the label and caches it' do
        expect(aat_term.rdf_label).to eq(["dog's-paw feet"])
        expect(Rails.cache.fetch(aat_term.send(:cache_key))).to eq(["dog's-paw feet"])
      end
    end
    context 'fetching label is not successful' do
      before do
        allow(aat_term).to receive_message_chain(:label,:call).with(any_args).and_return(nil)
      end

      it 'returns an error message' do
        expect(aat_term.rdf_label).to eq(["Error fetching #{aat_id}"])
      end
    end
  end
end
