require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder do
  let(:scope)    { double('Scope', blacklight_config: CatalogController.blacklight_config) }
  let(:builder)  { described_class.new(scope) }

  describe 'collection_types' do
    it { expect(builder.collection_types).to match_array([sequential_section_list_collection_type]) }
  end
end