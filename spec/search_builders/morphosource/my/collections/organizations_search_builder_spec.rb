require 'rails_helper'

RSpec.describe Morphosource::My::Collections::OrganizationsSearchBuilder do
  let(:scope)   { double('Scope', blacklight_config: CatalogController.blacklight_config) }
  let(:builder) { described_class.new(scope) }

  describe 'collection_types' do
    it { expect(builder.collection_types).to match_array([organization_collection_type]) }
  end

  describe 'models' do
    it { expect(builder.models).to match_array([OrganizationCollection]) }
  end
end