require 'rails_helper'

RSpec.describe Morphosource::PhysicalObjectsSearchService do

  subject { described_class.new(model, params) }

  let(:model) { BiologicalSpecimen }
  let(:params) { {} }

  describe '.call' do
    it 'instantiates the search service and calls it' do
      expect_any_instance_of(described_class).to receive(:call)
      described_class.call(model, params)
    end
  end

  describe '#call' do
    let!(:biospecs) do
      [
          BiologicalSpecimen.create(title: [ 'abc:123' ],
                                    catalog_number: [ '123' ],
                                    institution_code: [ 'INST1' ],
                                    collection_code: [ 'abc' ],
                                    vouchered: [ "Yes" ]),
          BiologicalSpecimen.create(title: [ 'abc:456' ],
                                    catalog_number: [ '456' ],
                                    institution_code: [ 'INST2' ],
                                    collection_code: [ 'abc' ],
                                    vouchered: [ "Yes" ]),
      ]
    end
    let!(:chos) do
      [
          CulturalHeritageObject.create(title: [ 'abc:456' ],
                                        catalog_number: [ '456' ],
                                        collection_code: [ 'abc' ],
                                        vouchered: [ "Yes" ])
      ]
    end
    describe 'no search params' do
      it 'returns SolrDocuments for all of the specified model' do
        results = subject.call
        expect(results).to match_array([ SolrDocument, SolrDocument ])
        expect(results.map(&:id)).to match_array([ biospecs[0].id, biospecs[1].id ])
      end
    end
    describe 'some search params' do
      let(:params) { { 'catalog_number' => '456', 'collection_code' => 'abc' } }
      it 'returns SolrDocuments for specified model that match search params' do
        results = subject.call
        expect(results).to match_array([ SolrDocument ])
        expect(results.map(&:id)).to match_array([ biospecs[1].id ])
      end
    end
    describe 'search params with institution_code' do
      let(:params) { { 'catalog_number' => '123', 'institution_code' => 'INST1', 'collection_code' => 'abc' } }
      it 'returns SolrDocuments for specified model that match search params' do
        results = subject.call
        expect(results).to match_array([ SolrDocument ])
        expect(results.map(&:id)).to match_array([ biospecs[0].id ])
      end
    end
    describe 'search params with no matches' do
      let(:params) { { 'catalog_number' => '456', 'institution_code' => 'INST1', 'collection_code' => 'abc' } }
      it 'returns no SolrDocuments when there are no models that match search params' do
        results = subject.call
        expect(results).to match_array([ ])
      end
    end
    describe 'taxonomy provided' do
      let!(:taxonomy) { valkyrie_create(:taxonomy_resource, title: [ 'Tax' ], taxonomy_genus: [ 'Test Genus' ], taxonomy_species: [ 'Test Species' ]) }
      let(:params) { { 'collection_code' => 'abc', 'taxonomy_genus' => 'Test Genus', 'taxonomy_species' => 'Test Species'  } }
      before do
        biospecs[1].taxonomy_id = [taxonomy.id]
        biospecs[1].save!
      end
      it 'returns SolrDocuments for specified model that match search params and belong to taxonomy' do
        results = subject.call
        expect(results).to match_array([ SolrDocument ])
        expect(results.map(&:id)).to match_array([ biospecs[1].id ])
      end
    end
  end

end
