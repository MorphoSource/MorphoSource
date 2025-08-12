require 'rails_helper'

RSpec.describe Morphosource::Dashboard::NestedCollectionsSearchBuilder do
  let(:access)          { :edit }
  let(:collection)      { double('Collection') }
  let(:scope)           { double('Scope', blacklight_config: CatalogController.blacklight_config) }
  let(:nest_direction)  { double('Nest Direction') }
  let(:hyrax_builder)   { Hyrax::Dashboard::NestedCollectionsSearchBuilder.new(access: access, collection: collection, scope: scope, nest_direction: nest_direction) }

  let(:builder)         { described_class.new(access: access, collection: collection, scope: scope, nest_direction: nest_direction) }

  describe '#models' do
    it 'includes OrganizationCollection in the models' do
      expect(builder.models).to include(OrganizationCollection)
    end

    it 'calls super and appends OrganizationCollection' do
      expect(builder.models).to eq(hyrax_builder.models + [OrganizationCollection])
    end
  end
 end
