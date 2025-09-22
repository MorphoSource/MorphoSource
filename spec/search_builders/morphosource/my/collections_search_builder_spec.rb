require 'rails_helper'

RSpec.describe Morphosource::My::CollectionsSearchBuilder do
  let(:scope)       { double('Scope', blacklight_config: CatalogController.blacklight_config) }
  let(:builder)     { described_class.new(scope) }

  describe 'models' do
    it { expect(builder.models).to match_array([::Collection, OrganizationCollection, MediaList, SequentialSectionList]) }
  end

  describe 'collection_types' do
    it { Hyrax::CollectionType.all }
  end
end