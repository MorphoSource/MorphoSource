require 'rails_helper'

RSpec.describe CatalogController, :type => :controller do

  describe "GET #index" do
    subject { described_class.new }
    it "renders the catalog template" do
      expect(subject.send :_layout, ['test']).to eq("catalog")
    end
  end

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has a blank thumbnail field' do
        expect(config.index.thumbnail_field).to eq('thumbnail_path_ss')
      end

      it 'has 1 facet field' do
        expect(facet_fields.count).to eq(1)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end
    end
  end
end
