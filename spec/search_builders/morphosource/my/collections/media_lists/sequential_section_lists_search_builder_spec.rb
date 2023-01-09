require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaLists::SequentialSectionListsSearchBuilder do
  let(:scope)                                     { double('Scope') }
  let(:builder)                                   { described_class.new(scope: scope) }
  let!(:sequential_section_list_collection_type)  { Hyrax::CollectionType.create(title: 'Sequential Section List', machine_id: 'sequential_section_list') }

  describe 'collection_types' do
    it { expect(builder.collection_types).to match_array([sequential_section_list_collection_type]) }
  end
end