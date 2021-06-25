require 'rails_helper'
include ActionDispatch::TestProcess
include Warden::Test::Helpers

RSpec.describe Morphosource::My::WorksController, type: :controller do
  let(:user)    { User.create(email: 'user@email.com', password: 'password') }
  let(:admins)  { Role.create(name: 'admin') }

  describe 'ms_default_facet_limit' do
    before do
      sign_in user
    end
    context 'user is an admin' do
      before do
        admins.users += [user]
        user.save!
      end
      it 'sets the ms default facet limit to 15' do
        expect(subject.ms_default_facet_limit).to eq(15)
      end
    end
    context 'user is not an admin' do
      before do
      end
      it 'sets the ms default facet limit to 999999' do
        expect(subject.ms_default_facet_limit).to eq(999999)
      end
    end
  end

  describe 'filter_facets' do
    let(:collection1)  { '0000001' }
    let(:collection2)  { '0000002' }
    let(:collection3)  { '0000003' }
    let(:collection4)  { '0000004' }
    let(:collection5)  { '0000005' }

    let(:viewable_collections_ids)  { [collection1, collection2, collection3] }
    let(:response)                  { double('response') }
    let(:facet_field)               { instance_double(Blacklight::Solr::Response::Facets::FacetField) }
    let(:filtered_facets)           { ['filtered_facet'] }

    let(:item1)   { double(Blacklight::Solr::Response::Facets::FacetItem, value: collection1, hits: 1) }
    let(:item2)   { double(Blacklight::Solr::Response::Facets::FacetItem, value: collection2, hits: 1) }
    let(:item3)   { double(Blacklight::Solr::Response::Facets::FacetItem, value: collection3, hits: 1) }
    let(:item4)   { double(Blacklight::Solr::Response::Facets::FacetItem, value: collection4, hits: 1) }
    let(:item5)   { double(Blacklight::Solr::Response::Facets::FacetItem, value: collection5, hits: 1) }

    let!(:items)            { [item1, item2, item3, item4, item5] }
    let(:authorized_items)  { [item1, item2, item3] }

    before do
      allow(subject).to receive_message_chain(:current_user,:admin?).and_return(false)
      subject.instance_variable_set(:@viewable_collections_ids, viewable_collections_ids)
      allow(subject).to receive(:filtered_facets) { filtered_facets }
      # mock response
      subject.instance_variable_set(:@response, response)
      allow(response).to receive(:aggregations) { {'filtered_facet' => facet_field } }
      allow(facet_field).to receive(:items) { items }
    end

    it 'removes unauthorized values from the facet' do
      subject.filter_facets
      expect(items.map(&:value)).to match_array([collection1, collection2, collection3])
    end
  end
end
