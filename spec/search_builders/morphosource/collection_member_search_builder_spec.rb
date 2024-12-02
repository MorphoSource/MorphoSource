require 'rails_helper'

RSpec.describe Morphosource::CollectionMemberSearchBuilder do
  let(:scope)       { double('Scope', blacklight_config: CatalogController.blacklight_config,) }
  let(:builder)     { described_class.new(scope: scope, collection_id: 'abc') }

  describe 'discovery_permissions' do
    it 'is edit, discover, download, read' do
      expect(builder.discovery_permissions).to match_array(['edit','discover','download','read'])
    end
  end
end
