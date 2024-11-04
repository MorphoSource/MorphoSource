require 'rails_helper'

RSpec.describe Morphosource::Collections::CollectionMemberService do
  let(:scope)       { double('Scope') }
  let(:collection)  { double('Collection', id: 'abc') }
  let(:params)      { double('Params') }

  subject { described_class.new(scope: scope, collection: collection, params: params) }

  describe 'works_search_builder' do
    it 'is an instance of CollectionMemberSearchBuilder' do
      expect(subject.works_search_builder.class).to eq(Morphosource::CollectionMemberSearchBuilder)
    end
  end
end
