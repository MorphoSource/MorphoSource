require 'rails_helper'

RSpec.describe CollectionsCatalogController, :type => :controller do

  describe '#current_catalog_search_path' do
    it 'returns the collections search path' do
      expect(controller.current_catalog_search_path).to eq(collection_search_path)
    end
  end

  describe 'Blacklight Configuration' do
    let(:config) { described_class.new.blacklight_config }
    describe 'search_builder_class' do
      it 'is the hyrax catalog search builder' do
        expect(config.search_builder_class).to eq(Morphosource::Catalog::CollectionsCatalogSearchBuilder)
      end

      it 'has a thumbnail field' do
        expect(config.index.thumbnail_field).to eq('thumbnail_path_ss')
      end
    end

    describe 'facet fields' do
      let(:facet_fields) { config.facet_fields }

      it 'has 3 facet fields' do
        expect(facet_fields.count).to eq(3)
      end

      describe 'generic type' do
        subject { facet_fields['generic_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Generic Type Sim")
        end
      end

      describe 'human readable type' do
        subject { facet_fields["type"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Project or Team")
          expect(subject.limit).to eq(10)
        end
      end

      describe 'linked organization' do
        subject { facet_fields["organization"] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Organization")
          expect(subject.limit).to eq(10)
        end
      end
    end

    describe 'index fields' do
      let(:index_fields) { config.index_fields }

      describe 'title' do
        subject { index_fields['title_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq("Title")
          expect(subject.field).to eq('title_tesim')
        end
      end

      describe 'description' do
        subject { index_fields['description_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Description')
          expect(subject.field).to eq('description_tesim')
        end
      end

      describe 'depositor' do
        subject { index_fields['depositor_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Creator')
          expect(subject.helper_method).to eq(:link_to_profile)
          expect(subject.field).to eq('depositor_tesim')
        end

      end

      describe 'date_uploaded' do
        subject { index_fields['date_uploaded_dtsi'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Date Created')
          expect(subject.helper_method).to eq(:human_readable_date)
          expect(subject.field).to eq('date_uploaded_dtsi')
        end
      end
    end

    describe 'search fields' do
      let(:search_fields) { config.search_fields }
      describe 'all_fields' do
        subject { search_fields['all_fields'] }
        it 'includes id' do
          expect(subject.solr_parameters[:qf]).to include('id')
        end
      end
    end
  end
end
