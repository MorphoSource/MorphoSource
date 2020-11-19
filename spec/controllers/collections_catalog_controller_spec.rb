require 'rails_helper'

RSpec.describe CollectionsCatalogController, :type => :controller do

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
        subject { facet_fields['human_readable_type_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Type")
          expect(subject.limit).to eq(5)
        end
      end

      describe 'linked organization' do
        subject { facet_fields['linked_organization_sim'] }
        it 'has the correct attributes' do
          expect(subject.label).to eq("Organization")
          expect(subject.limit).to eq(5)
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

      describe 'depositor' do
        subject { index_fields['depositor_tesim'] }

        it 'has the correct attributes' do
          expect(subject.label).to eq('Creator')
          expect(subject.helper_method).to eq(:link_to_profile)
          expect(subject.field).to eq('depositor_tesim')
        end

      end
      describe 'collection_member_count' do
        subject { index_fields['collection_member_count'] }

        it 'has the correct attributes' do
          expect(subject.accessor).to eq('collection_member_count')
          expect(subject.label).to eq('Number of Members')
          expect(subject.field).to eq('collection_member_count')
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
  end
end
