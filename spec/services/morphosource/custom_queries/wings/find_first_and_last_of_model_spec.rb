# frozen_string_literal: true

require 'rails_helper'

return if Hyrax.config.disable_wings

RSpec.describe Morphosource::CustomQueries::Wings::FindFirstAndLastOfModel do
  let(:query_service) { Valkyrie::MetadataAdapter.adapters[:wings_adapter].query_service }
  subject(:query_handler) { described_class.new(query_service: query_service) }

  before do
    allow_any_instance_of(Taxonomy).to receive(:readonly?).and_return(false)
  end

  describe '#find_first_of_model' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(query_handler.find_first_of_model(model: TaxonomyResource)).to be_nil
      end
    end

    context 'when AF works exist' do
      let!(:first_work) { create(:taxonomy, title: ['First AF Work']) }
      let!(:second_work) { create(:taxonomy, title: ['Second AF Work']) }

      it 'returns the first work as a Valkyrie resource' do
        result = query_handler.find_first_of_model(model: TaxonomyResource)
        expect(result).to be_a Valkyrie::Resource
        expect(result.id.to_s).to eq first_work.id
      end
    end
  end

  describe '#find_last_of_model' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(query_handler.find_last_of_model(model: TaxonomyResource)).to be_nil
      end
    end

    context 'when AF works exist' do
      let!(:first_work) { create(:taxonomy, title: ['First AF Work']) }
      let!(:second_work) { create(:taxonomy, title: ['Second AF Work']) }

      it 'returns the last work as a Valkyrie resource' do
        result = query_handler.find_last_of_model(model: TaxonomyResource)
        expect(result).to be_a Valkyrie::Resource
        expect(result.id.to_s).to eq second_work.id
      end
    end
  end
end
