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
        expect(config.index.thumbnail_field).to eq('')
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

    describe 'show fields' do
      let(:show_fields) { config.show_fields }
      describe 'objects' do
        describe 'taxonomy' do
          subject { show_fields["taxonomy_tesim"] }
          it 'has the correct attributes' do
            expect(subject.key).to eq("taxonomy_tesim")
            expect(subject.field).to eq("taxonomy_tesim")
            expect(subject.label).to eq("Taxonomy Tesim")
          end
        end
      end
    end

    describe 'search fields' do
      let(:search_fields) { config.search_fields }
      describe 'all_fields' do
        subject { search_fields['all_fields'] }
        it 'includes taxonomy' do
          expect(subject.solr_parameters[:qf]).to include('taxonomy_tesim')
        end
      end
    end
  end
end
