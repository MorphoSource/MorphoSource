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

  describe '.exists?' do
    let!(:resource) { valkyrie_create(:taxonomy_resource, title: ['Exists Resource'], with_index: false) }

    it 'returns true when find_by finds a resource' do
      expect(TaxonomyResource.exists?(id: resource.id)).to be true
    end

    it 'returns false when find_by does not find a resource' do
      expect(TaxonomyResource.exists?(id: 'missing')).to be false
    end

    it 'returns false when find_by raises an error' do
      allow(TaxonomyResource).to receive(:find_by).and_raise(StandardError)
      expect(TaxonomyResource.exists?(id: resource.id)).to be false
    end
  end
end
