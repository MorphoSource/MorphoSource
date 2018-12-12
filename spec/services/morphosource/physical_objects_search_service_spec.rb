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
                                    collection_code: [ 'abc' ],
                                    vouchered: [ true ]),
          BiologicalSpecimen.create(title: [ 'abc:456' ],
                                    catalog_number: [ '456' ],
                                    collection_code: [ 'abc' ],
                                    vouchered: [ true ]),
      ]
    end
    let!(:chos) do
      [
          CulturalHeritageObject.create(title: [ 'abc:456' ],
                                        catalog_number: [ '456' ],
                                        collection_code: [ 'abc' ],
                                        vouchered: [ true ])
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
    describe 'institution provided' do
      let!(:institution) { Institution.create(title: [ 'Inst' ], institution_code: [ 'xyz' ]) }
      let(:params) { { 'collection_code' => 'abc', 'institution_code' => 'xyz' } }
      before do
        institution.ordered_members << biospecs[1]
        institution.save!
      end
      it 'returns SolrDocuments for specified model that match search params and belong to institution' do
        results = subject.call
        expect(results).to match_array([ SolrDocument ])
        expect(results.map(&:id)).to match_array([ biospecs[1].id ])
      end
    end
  end

end
