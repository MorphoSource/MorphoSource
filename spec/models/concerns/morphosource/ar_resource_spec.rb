# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::ArResource do
  before do
    allow_any_instance_of(Taxonomy).to receive(:readonly?).and_return(false)
  end

  describe '.first' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(TaxonomyResource.first).to be_nil
      end
    end

    context 'when Valkyrie resources exist' do
      let!(:first_resource) { valkyrie_create(:taxonomy_resource, title: ['First Resource'], with_index: false) }
      let!(:second_resource) { valkyrie_create(:taxonomy_resource, title: ['Second Resource'], with_index: false) }

      it 'returns the oldest resource' do
        result = TaxonomyResource.first
        expect(result).to be_a TaxonomyResource
        expect(result.id).to eq first_resource.id
      end
    end

    context 'when only AF works exist' do
      let!(:af_work) { create(:taxonomy, title: ['AF Work']) }

      it 'falls back to Wings and returns the AF work as a Valkyrie resource' do
        result = TaxonomyResource.first
        expect(result).to be_a Valkyrie::Resource
        expect(result.id.to_s).to eq af_work.id
      end
    end
  end

  describe '.last' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(TaxonomyResource.last).to be_nil
      end
    end

    context 'when Valkyrie resources exist' do
      let!(:first_resource) { valkyrie_create(:taxonomy_resource, title: ['First Resource'], with_index: false) }
      let!(:second_resource) { valkyrie_create(:taxonomy_resource, title: ['Second Resource'], with_index: false) }

      it 'returns the newest resource' do
        result = TaxonomyResource.last
        expect(result).to be_a TaxonomyResource
        expect(result.id).to eq second_resource.id
      end
    end

    context 'when only AF works exist' do
      let!(:af_work) { create(:taxonomy, title: ['AF Work']) }

      it 'falls back to Wings and returns the AF work as a Valkyrie resource' do
        result = TaxonomyResource.last
        expect(result).to be_a Valkyrie::Resource
        expect(result.id.to_s).to eq af_work.id
      end
    end
  end
end
