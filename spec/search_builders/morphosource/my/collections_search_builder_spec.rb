require 'rails_helper'

RSpec.describe Morphosource::My::CollectionsSearchBuilder do
  let(:scope)       { double('Scope') }
  let(:builder)     { described_class.new(scope: scope) }

  describe 'models' do
    it { expect(builder.models).to match_array([::Collection]) }
  end

  describe 'collection_types' do
    it { Hyrax::CollectionType.all }
  end
end