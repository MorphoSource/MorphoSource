require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaListsSearchBuilder do
  let(:scope)                       { double('Scope') }
  let(:builder)                     { described_class.new(scope: scope) }
  let!(:media_list_collection_type)  { Hyrax::CollectionType.create(title: 'Media List', machine_id: 'media_list') }

  describe 'collection_types' do
    it { expect(builder.collection_types).to match_array([media_list_collection_type]) }
  end
end