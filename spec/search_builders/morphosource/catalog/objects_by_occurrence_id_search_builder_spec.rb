# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Morphosource::Catalog::ObjectsByOccurrenceIdSearchBuilder do
  let(:user)    { FactoryBot.create(:user) }
  let(:ability) { Ability.new(user) }
  let(:scope)   { double('scope', blacklight_config: ObjectsCatalogController.blacklight_config, current_ability: ability, params: {}) }
  let(:occurrence_id) { 'urn:uuid:21f5b097-ffb7-4821-9a79-deb3656d8b28' }
  let(:builder) { described_class.new(scope: scope, occurrence_id: occurrence_id) }

  describe 'processor_chain' do
    it 'includes :filter_by_occurrence_id' do
      expect(builder.processor_chain).to include(:filter_by_occurrence_id)
    end
  end

  describe '#filter_by_occurrence_id' do
    let(:solr_params) { { fq: [] } }

    it 'adds an fq filter on occurrence_id_ssim' do
      builder.filter_by_occurrence_id(solr_params)
      expect(solr_params[:fq]).to include("occurrence_id_ssim:\"#{occurrence_id}\"")
    end

    context 'when fq key is absent from solr_params' do
      let(:solr_params) { {} }

      it 'initializes fq and adds the filter' do
        builder.filter_by_occurrence_id(solr_params)
        expect(solr_params[:fq]).to include("occurrence_id_ssim:\"#{occurrence_id}\"")
      end
    end

    context 'when occurrence_id contains a double quote' do
      let(:occurrence_id) { 'urn:example:id"with"quotes' }

      it 'escapes double quotes to prevent Solr injection' do
        builder.filter_by_occurrence_id(solr_params)
        expect(solr_params[:fq]).to include('occurrence_id_ssim:"urn:example:id\"with\"quotes"')
      end
    end
  end
end
