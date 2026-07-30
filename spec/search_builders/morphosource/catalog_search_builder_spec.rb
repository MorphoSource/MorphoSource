require 'rails_helper'

RSpec.describe Morphosource::CatalogSearchBuilder do
  let(:scope) do
    double('scope', blacklight_config: MediaCatalogController.blacklight_config, params: {})
  end
  let(:builder) { described_class.new(scope) }
  let(:owner_facet) { MediaCatalogController.blacklight_config.facet_fields['owner'] }

  describe '#add_facet_filter' do
    it 'adds a terms filter containing every matching owner ID' do
      allow(builder).to receive(:fetch_owner_ids_by_name).with('matching owner')
        .and_return(%w[user-id organization-id])
      solr_params = {}

      builder.send(:add_facet_filter, owner_facet, 'matching owner', solr_params)

      expect(solr_params[:fq]).to eq([
        '{!terms f=user_with_ownership_ssi}user-id,organization-id'
      ])
    end

    it 'adds an always-false filter when no owner matches' do
      allow(builder).to receive(:fetch_owner_ids_by_name).with('missing owner').and_return([])
      solr_params = {}

      builder.send(:add_facet_filter, owner_facet, 'missing owner', solr_params)

      expect(solr_params[:fq]).to eq(['{!frange l=1 u=0}1'])
    end
  end
end
