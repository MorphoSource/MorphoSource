require 'rails_helper'

RSpec.describe CatalogController, :type => :controller do

  describe 'access_controlled_facets' do
    it { expect(described_class).to respond_to(:access_controlled_facets) }
  end

  describe "GET #index" do
    subject { described_class.new }
    it "renders the catalog template" do
      expect(subject.send :_layout, ['test']).to eq("catalog")
    end
  end

  describe 'remove_hidden_facet_items' do
    let(:response) do
    instance_double(Blacklight::Solr::Response,
                    prev_page: nil,
                    next_page: 2,
                    total_pages: 3,
                    aggregations: aggregations)
    end
    let(:facet_item1) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'value1') }
    let(:facet_item2) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'value2') }
    let(:facet_item3) { Blacklight::Solr::Response::Facets::FacetItem.new(value: 'value3') }
    let(:facet_items) { [facet_item1, facet_item2, facet_item3] }
    let(:facet) { Blacklight::Solr::Response::Facets::FacetField.new("test_facet", facet_items) }
    let(:access_controlled_facets) { [facet.name] }

    let(:aggregations) do
    { facet.name => facet }
  end

    before do
      controller.instance_variable_set(:@response, response)
      allow(controller).to receive(:access_controlled_facets).and_return(access_controlled_facets)
      allow(controller).to receive(:safe_list).with(facet.name).and_return([facet_item1.value])
    end

    it 'removes facet items not on the safe list' do
      controller.remove_hidden_facet_items
      expect(facet.items).to match_array([facet_item1])
    end
  end

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 1 facet field' do
        expect(facet_fields.count).to eq(1)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end
    end
  end
end
