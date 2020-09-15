require 'rails_helper'

RSpec.describe Morphosource::Catalog::MediaCatalogSearchBuilder do
  let(:scope)   { double('Scope') }
  subject       { described_class.new(scope) }

  describe 'filter_collection_facet_for_access' do
    let(:user)    { User.create() }
    let(:ability) { Ability.new(user) }
    before do
      allow(subject).to receive(:current_user).and_return(user)
      allow(subject).to receive(:current_ability).and_return(ability)
    end
    context 'user is an admin' do
      before do
        allow(ability).to receive(:admin?).and_return(true)
      end
      it 'returns nil' do
        expect(subject.filter_collection_facet_for_access({})).to be(nil)
      end
    end
    context 'user is signed in' do
      before do
        allow(subject).to receive(:current_user).and_return(user)
        allow(Morphosource::Catalog::Facets::CollectionsPermissionsService).to receive(:ids_for_collection_facet).with(ability: ability).and_return(['col1', 'col2', 'col3'])
      end
      it 'returns allowed collection ids' do
        expect(subject.filter_collection_facet_for_access({})).to match_array(['col1', 'col2', 'col3'])
      end
    end
    context 'user is not signed in' do
      before do
        allow(subject).to receive(:current_user).and_return(nil)
        allow(Morphosource::Catalog::Facets::CollectionsPermissionsService).to receive(:public_collection_ids).and_return(['pub_col1', 'pub_col2', 'pub_col3'])
      end
      it 'returns allowed collection ids' do
        expect(subject.filter_collection_facet_for_access({})).to match_array(['pub_col1', 'pub_col2', 'pub_col3'])
      end
    end
  end

  describe 'models' do
    it { expect(subject.send(:models)).to eq([::Media]) }
  end
end
