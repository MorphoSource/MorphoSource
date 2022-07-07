require 'rails_helper'

RSpec.describe Morphosource::ControlledVocabularies::Getty::Aat do
  let(:cache_key_prefix) { 'morphosource_getty_aat_label-v1-' }
  let(:service_name)  { 'aat' }

  it 'has a cache_key_prefix' do
    expect(subject.cache_key_prefix).to eq(cache_key_prefix)
  end

  it 'has a service_name' do
    expect(subject.service_name).to eq(service_name)
  end

  describe 'label' do
    context 'Faraday response is an error' do
      let(:item) { { :status=>:error,
                     :message=>"error message" } }

      it 'returns nil' do
        expect(subject.label.call(item)).to be(nil)
      end
    end
    context 'Faraday response is not an error' do
      let(:preferred_label_value) { 'getty english label' }
      let(:item) { { :status => :success,
                     :data => {
                       "results" => {
                         "bindings" => [{"Subject"=> {"type"=>"uri", "value"=>"http://vocab.getty.edu/aat/300438369"}, "Predicate"=> {"type"=>"uri", "value"=>"http://www.w3.org/2004/02/skos/core#prefLabel"}, "Object"=> {"xml:lang"=>"en", "type"=>"literal", "value"=>"#{preferred_label_value}"}}]
                        }
                      }
                    } }
      it 'returns the preferred label value' do
        expect(subject.label.call(item)).to eq(preferred_label_value)
      end
    end
  end
end
