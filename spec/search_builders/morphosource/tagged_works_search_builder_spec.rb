require 'rails_helper'

RSpec.describe Morphosource::TaggedWorksSearchBuilder do
  let(:scope)       { double('Scope', params: { tag: 'purple' }) }
  let(:builder)     { described_class.new(scope) }
  let(:solr_params) { { fq: [] } }

  describe 'processor_chain' do
    it 'includes add_access_controls_to_solr_params, show_only_works_with_keyword' do
      expect(builder.processor_chain).to include(:add_access_controls_to_solr_params, :show_only_works_with_keyword)
    end
  end

  describe "#only_works?" do
    it 'returns true' do
      expect(builder.only_works?).to be(true)
    end
  end

  describe '#models' do
    it 'allows only media' do
      expect(builder.models).to match_array([Media])
    end
  end

  describe '#show_only_works_with_keyword' do
    it "filters media works by keyword" do
      builder.show_only_works_with_keyword(solr_params)
      expect(solr_params[:fq]).to eq(["keyword_tesim:(purple)"])
    end
  end
end
