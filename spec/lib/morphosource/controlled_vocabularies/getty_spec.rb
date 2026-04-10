require 'rails_helper'

RSpec.describe Morphosource::ControlledVocabularies::Getty do
  let(:aat_id)    { '300172528' }
  let(:aat_term)  { Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI("http://vocab.getty.edu/aat/#{aat_id}")) }
  let(:non_id)    { '000000' }
  let(:non_term)  { Morphosource::ControlledVocabularies::Getty::Aat.new(::RDF::URI("http://vocab.getty.edu/aat/#{non_id}")) }

  describe 'AAT API' do
    api_test_url = 'http://vocab.getty.edu/aat/300172528.json'
    skip_message = "Unable to access #{api_test_url}"

    if ApiHelpers.external_api_is_up?(api_test_url)
      context 'is available' do
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
            it 'returns an error message' do
              expect(non_term.rdf_label).to eq(["Error fetching #{non_id}"])
            end
          end
        end
      end
    else
      context 'is unavailable', skip: "#{skip_message}" do
        it {}
      end
    end
  end
end
