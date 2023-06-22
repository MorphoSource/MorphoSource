require 'rails_helper'

RSpec.describe Morphosource::My::Collections::MediaListsSearchBuilder do
  let(:scope)                       { double('Scope') }
  let(:builder)                     { described_class.new(scope: scope) }

  describe 'collection_types' do
    it { expect(builder.collection_types).to match_array([media_list_collection_type]) }
  end
end