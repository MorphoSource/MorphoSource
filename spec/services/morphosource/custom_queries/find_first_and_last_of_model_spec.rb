# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Morphosource::CustomQueries::FindFirstAndLastOfModel do
  let(:query_service) { Hyrax.query_service.postgres_service }
  subject(:query_handler) { described_class.new(query_service: query_service) }

  describe '#find_first_of_model' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(query_handler.find_first_of_model(model: TaxonomyResource)).to be_nil
      end
    end

    context 'when resources exist' do
      let!(:first_resource) { valkyrie_create(:taxonomy_resource, title: ['First Resource'], with_index: false) }
      let!(:second_resource) { valkyrie_create(:taxonomy_resource, title: ['Second Resource'], with_index: false) }

      it 'returns the oldest resource by created_at' do
        result = query_handler.find_first_of_model(model: TaxonomyResource)
        expect(result).to be_a TaxonomyResource
        expect(result.id).to eq first_resource.id
      end

      it 'does not return resources of a different model' do
        Hyrax.persister.save(resource: Hyrax::FileSet.new)

        result = query_handler.find_first_of_model(model: TaxonomyResource)
        expect(result.id).to eq first_resource.id
      end
    end
  end

  describe '#find_last_of_model' do
    context 'when no resources exist' do
      it 'returns nil' do
        expect(query_handler.find_last_of_model(model: TaxonomyResource)).to be_nil
      end
    end

    context 'when resources exist' do
      let!(:first_resource) { valkyrie_create(:taxonomy_resource, title: ['First Resource'], with_index: false) }
      let!(:second_resource) { valkyrie_create(:taxonomy_resource, title: ['Second Resource'], with_index: false) }

      it 'returns the newest resource by created_at' do
        result = query_handler.find_last_of_model(model: TaxonomyResource)
        expect(result).to be_a TaxonomyResource
        expect(result.id).to eq second_resource.id
      end
    end
  end
end
