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

  describe '#manager_links' do
    let(:manager) { FactoryBot.create(:contributor) }

    before { allow(collection).to receive(:managers).and_return([manager]) }

    it 'renders every manager by default' do
      expected = %(<a href="/users/#{manager.ms_id}">#{manager.name_or_email}</a>)
      expect(subject.manager_links).to eq(expected)
    end
  end
end
