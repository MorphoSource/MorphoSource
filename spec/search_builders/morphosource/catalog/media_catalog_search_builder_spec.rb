# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Catalog::MediaCatalogSearchBuilder do
  let(:scope)   { double('scope', blacklight_config: MediaCatalogController.blacklight_config, params: {}) }
  let(:builder) { described_class.new(scope) }

  describe 'processor_chain' do
    it 'includes :add_object_occurrence_id_filter' do
      expect(builder.processor_chain).to include(:add_object_occurrence_id_filter)
    end
  end

  describe '#add_object_occurrence_id_filter' do
    let(:solr_params) { { fq: [] } }

    context 'when object_occurrence_id param is present' do
      let(:occurrence_id) { 'urn:uuid:21f5b097-ffb7-4821-9a79-deb3656d8b28' }
      let(:builder) { described_class.new(scope).with(object_occurrence_id: occurrence_id) }

      it 'adds an fq filter on occurrence_id_ssim' do
        builder.add_object_occurrence_id_filter(solr_params)
        expect(solr_params[:fq]).to include("occurrence_id_ssim:\"#{occurrence_id}\"")
      end
    end

    context 'when object_occurrence_id param is absent' do
      let(:builder) { described_class.new(scope).with({}) }

      it 'does not modify fq' do
        builder.add_object_occurrence_id_filter(solr_params)
        expect(solr_params[:fq]).to be_empty
      end
    end

    context 'when object_occurrence_id contains a double quote' do
      let(:occurrence_id) { 'urn:example:id"bad"value' }
      let(:builder) { described_class.new(scope).with(object_occurrence_id: occurrence_id) }

      it 'escapes double quotes to prevent Solr injection' do
        builder.add_object_occurrence_id_filter(solr_params)
        expect(solr_params[:fq]).to include('occurrence_id_ssim:"urn:example:id\"bad\"value"')
      end
    end
  end
end
