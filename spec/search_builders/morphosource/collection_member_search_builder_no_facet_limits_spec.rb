require 'rails_helper'

RSpec.describe Morphosource::CollectionMemberSearchBuilderNoFacetLimits do
  let(:scope)       { double('Scope') }
  let(:collection)  { double('Collection') }
  let(:builder)     { described_class.new(scope: scope, collection: collection) }

  describe 'discovery_permissions' do
    it 'is edit, discover, download, read' do
      expect(builder.discovery_permissions).to match_array(['edit','discover','download','read'])
    end
  end
end
