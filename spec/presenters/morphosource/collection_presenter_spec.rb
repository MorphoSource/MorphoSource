require 'rails_helper'

RSpec.describe Morphosource::CollectionPresenter do
  let(:collection)      { FactoryBot.build(:team, id: '123') }
  let(:collection_doc)  { SolrDocument.new(collection.to_solr) }

  subject { described_class.new(collection_doc, double)}

  before do
    allow(Collection).to receive(:find).with(collection.id).and_return(collection)
    allow(collection).to receive(:managers).and_return([])
  end

  describe 'model' do
    it { expect(subject.model).to be_a(Hyrax::SolrDocumentBehavior::ModelWrapper) }
  end
end